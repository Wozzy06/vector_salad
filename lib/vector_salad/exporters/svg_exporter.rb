require_relative 'base_exporter.rb'
Dir.glob(File.expand_path('../../standard_shapes/*.rb', __FILE__)).each do |file|
  require file
end

module VectorSalad
  module Exporters
    class SvgExporter < BaseExporter
      def header
        puts <<-END.gsub(/^ {10}/, '')
          <svg version="1.1"
               xmlns="http://www.w3.org/2000/svg"
               width="#{canvas_width}"
               height="#{canvas_height}">
        END
      end

      def footer
        puts '</svg>'
      end

      def self.options(options)
        out = ''
        options.each do |k, v|
          out << " #{k.to_s.gsub(/_/, ?-)}=\"#{v.to_s.gsub(/_/, ?-)}\""
        end
        out
      end
    end
  end
end


module VectorSalad
  module StandardShapes
    class Path
      def to_svg
        svg = '<path d="'
        svg << to_svg_d_attribute
        svg << '"'
        svg << VectorSalad::Exporters::SvgExporter.options(@options)
        svg << '/>'
      end

      def to_svg_d_attribute
        nodes = to_bezier_path.nodes
        svg = ''
        svg << "M #{nodes[0].x} #{nodes[0].y}"

        nodes[1..-1].each_index do |j|
          i = j+1

          n = nodes[i]
          case n.type
          when :cubic
            if nodes[i-1].type == :node
              svg << " C #{n.x} #{n.y}"
            elsif nodes[i-2].type == :node && nodes[i-1].type == :cubic
              svg << ", #{n.x} #{n.y}"
            end
          when :quadratic
            svg << " Q #{n.x} #{n.y}"
          when :node
            if nodes[i-1].type == :cubic || nodes[i-1].type == :quadratic
              svg << ", #{n.x} #{n.y}"
            elsif nodes[i-1].type == :node
              svg << " L #{n.x} #{n.y}"
            end
          else
            raise "The SVG exporter doesn't support #{n.type} node type."
          end
        end

        svg << ' Z' if @closed
        svg
      end
    end

    class BasicShape
      def to_svg
        to_path.to_svg
      end
    end

    class MultiPath
      def to_svg
        svg = '<path d="'
        paths.each do |path|
          svg << " #{path.to_svg_d_attribute}"
        end
        svg << '"'
        svg << VectorSalad::Exporters::SvgExporter.options(@options)
        svg << '/>'
      end
    end

    class Circle
      def to_svg
        svg = "<circle cx=\"#{at[0]}\" cy=\"#{at[1]}\" r=\"#{radius}\""
        svg << VectorSalad::Exporters::SvgExporter.options(@options)
        svg << '/>'
      end
    end

    class Oval
      def to_svg
        svg = "<ellipse cx=\"#{at[0]}\" cy=\"#{at[1]}\""
        svg << " rx=\"#{width}\" ry=\"#{height}\""
        svg << VectorSalad::Exporters::SvgExporter.options(@options)
        svg << '/>'
      end
    end

    class Square
      def to_svg
        svg = "<rect x=\"#{at[0]}\" y=\"#{at[1]}\""
        svg << " width=\"#{size}\" height=\"#{size}\""
        svg << VectorSalad::Exporters::SvgExporter.options(@options)
        svg << '/>'
      end
    end

    class Rect
      def to_svg
        svg = "<rect x=\"#{at[0]}\" y=\"#{at[1]}\""
        svg << " width=\"#{width}\" height=\"#{height}\""
        svg << VectorSalad::Exporters::SvgExporter.options(@options)
        svg << '/>'
      end
    end
  end
end
