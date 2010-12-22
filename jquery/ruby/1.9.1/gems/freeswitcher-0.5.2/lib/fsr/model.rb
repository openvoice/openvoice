module FSR
  module Model
    def to_hash
      Hash[fields.map { |f| [f,self.send(f.to_sym)] }]
    end

    def inspect
      "<##{self.object_id} #{self.class} - #{self.to_hash}>"
    end
  end
end
