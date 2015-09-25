require "vector_salad/standard_shapes/basic_shape"
require "vector_salad/standard_shapes/n"
require "vector_salad/interpolate"

module VectorSalad
  module StandardShapes
    # MultiPath shape is a collection of Paths.
    # It is mainly to store the result of {Clip} operations.
    class MultiPath < BasicShape
      attr_reader :paths, :closed

      # See {Path} for details on constructing paths.
      #
      # @example
      #   new(
      #     Path.n([0,0], [0,300], [300,300], [300,0], [0,0]),
      #     Path.n([100,100], [200,100], [200,200], [100,200], [100,100])
      #   )
      # @example
      #   new(
      #     [[0,0], [0,300], [300,300], [300,0], [0,0]],
      #     [[100,100], [200,100], [200,200], [100,200], [100,100]]
      #   )
      Contract Args[Or[Array, Path]], { closed: Maybe[Bool] } => MultiPath
      def initialize(*paths, closed: true, **options)
        paths.each do |path|
          path = path.instance_of?(Array) ? Path.new(*path) : path
          @paths = Array(@paths) << path
        end

        @closed = closed
        @options = options
        self
      end

      # Move the MultiPath absolutely.
      Contract Num, Num => MultiPath
      def [](x, y)
        each_send(:[], x, y)
      end

      # Move the MultiPath relatively.
      Contract Num, Num => MultiPath
      def move(x, y)
        each_send(:move, x, y)
      end

      # Rotates the MultiPath by the specified angle about the origin.
      Contract Num => MultiPath
      def rotate(angle)
        each_send(:rotate, angle)
      end

      # Scale a MultiPath by multiplier about the origin.
      Contract Num => MultiPath
      def scale(multiplier)
        each_send(:scale, multiplier)
      end

      # Convert the shape to a path
      def to_path
        self
      end

      # Convert the complex paths in the MultiPath to bezier paths.
      def to_bezier_path
        self.class.new(*@paths.map(&:to_bezier_path), **@options)
      end

      # Convert the complex paths in the MultiPath to cubic bezier paths only.
      def to_cubic_path
        self.class.new(*@paths.map(&:to_cubic_path), **@options)
      end

      # Convert the complex paths in the MultiPath to simple paths.
      def to_simple_path
        self.class.new(*@paths.map(&:to_simple_path), **@options)
      end

      # Returns self
      def to_multi_path
        self
      end

      # Return an array of paths that are and array of node coordinates.
      def to_a
        @paths.map(&:to_a)
      end

      private

      def each_send(method, *args, &block)
        self.class.new(*@paths.map do |path|
          path.send(method, *args, &block)
        end, closed: @closed, **@options)
      end
    end
  end
end