require 'chunky_png'
require 'daemons'

module ChunkyPNG
  class Image
    attr_reader :center_x, :center_y, :radius

    def swimming_pool! center_x, center_y, radius
      @center_x = center_x # 181
      @center_y = center_y # 111
      @radius = radius # 125
    end

    def rat_track!
      pixels.map! do |pixel|
        (Color.g(pixel) + Color.r(pixel) + Color.g(pixel)) / 3 < 15 ? 0 : pixel
      end

      # circle(@center_x, @center_y, @radius, Color.parse(:red))
    end

    def in_circle? x, y
      (x - @center_x) ** 2 + (y - @center_y) ** 2 <= @radius ** 2
    end

    def area_value x, y, size
      sum = 0
      for i in x...(x + size)
        for j in y...(y + size)
          if i < width && j < height
            sum += self[i,j] if in_circle? i, j
          end
        end
      end
      sum
    end

    def find_rat
      rat_track!

      size = 30
      result = []
      (0...width).step(size) { |i|
        (0...height).step(size) { |j|
          sum = area_value i, j, size
          if sum > 0
            result << [i, j, size, sum]
          end
        }
      }
      result = result.sort!{ |a,b| a[3] <=> b[3] }.pop(2)

      result.each do |k|
        rect(k[0], k[1], k[0] + k[2], k[1] + k[2], Color.parse(:blue))
      end
    end
  end
end

Daemons.daemonize

# public/videos/000000
Dir["#{ARGV[0]}/*.png"].sort.each do |f|
  image = ChunkyPNG::Image.from_file(f)
  image.swimming_pool! 181, 111, 125
  image.find_rat
  image.save(f.gsub('frame', 'output_frame'))
end
