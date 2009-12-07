class Server < ActiveRecord::Base
  attr_accessible :name, :fqdn, :ipaddress, :description
  
  STATUS_ACTIVE = 1
  STATUS_LOCKED = 2
  
  validates_uniqueness_of :name, :case_sensitive => false
  validates_uniqueness_of :fqdn, :case_sensitive => false
  validates_format_of :name, :with => /\A[a-zA-Z0-9_-]*\Z/
  
  named_scope :active, :conditions => { :status => STATUS_ACTIVE }
  
  def active?
    self.status == STATUS_ACTIVE
  end
end
