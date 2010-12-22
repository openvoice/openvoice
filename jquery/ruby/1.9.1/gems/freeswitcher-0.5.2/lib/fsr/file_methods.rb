module FSR
  module App
    module FileMethods
      def test_files *files
        files.each do |file|
          next unless file =~ /^\//
          next if File.open(file){|io| io.stat.file? }
          raise(ArgumentError, "No such file - #{file}") 
        end
        true
      end
    end
  end
end
