require "fsr/database"
module FSR
  module Database
    module CallLimit
      DB = Sequel.connect("sqlite:///" + File.join(FSR::FS_DB_PATH, "call_limit.db"))
      class LimitData < Sequel::Model
      end
      LimitData.set_dataset :limit_data

      class DbData < Sequel::Model
      end
      DbData.set_dataset :db_data

      class GroupData < Sequel::Model
      end
      GroupData.set_dataset :group_data

      LimitData.db, DbData.db, GroupData.db = [DB] * 3
    end
  end
end
