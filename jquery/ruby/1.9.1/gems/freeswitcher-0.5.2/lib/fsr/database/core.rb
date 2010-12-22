require "fsr/database"
# This module maps to the Free Switch core.db database
#
# TODO Separate these models into their own subdirectories
module FSR
  module Database
    module Core
      DB = Sequel.connect("sqlite://" + File.join(FSR::FS_DB_PATH, "core.db"))

      class Complete < Sequel::Model
      end
      Complete.set_dataset :complete

      class Alias < Sequel::Model
      end

      class Channel < Sequel::Model
      end

      class Call < Sequel::Model
      end

      class Interface < Sequel::Model
      end

      class Task < Sequel::Model
      end
    end
  end
end
