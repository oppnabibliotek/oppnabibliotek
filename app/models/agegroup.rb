# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
# == Schema Information
# Schema version: 55
#
# Table name: agegroups
#
#  id             :integer(4)      not null, primary key
#  name           :string(255)
#  targetgroup_id :integer(4)
#  from           :integer(4)
#  to             :integer(4)
#  created_at     :datetime
#  updated_at     :datetime
#

class Agegroup < ActiveRecord::Base
   belongs_to :targetgroup
end
