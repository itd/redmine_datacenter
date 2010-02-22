module Redmine
  module Acts
    module Ipaddress
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_ipaddress(options = {})
          raise "You must define attributes which will acts_as_ipaddress!" if options[:attributes].blank?
          Array(options[:attributes]).each do |attr|
            class_eval <<-"SRC"
              def #{attr}
                attr = read_attribute(:#{attr})
                attr = attr.to_i if attr == attr.to_i.to_s
                IPAddr.new(attr, Socket::AF_INET).to_s unless attr.blank?
              end
           
              def #{attr}=(value)
                if value == value.to_i.to_s && value.to_i <= 32 #netmask!
                  value = IPAddr.new("255.255.255.255/"+value.to_s).to_s
                end
                write_attribute(:#{attr}, IPAddr.new(value).to_i) if IPAddr.valid?(value)
              end
            SRC
          end
          #send :include, Redmine::Acts::Attachable::InstanceMethods
        end
      end
    end
  end
end
ActiveRecord::Base.send(:include, Redmine::Acts::Ipaddress)