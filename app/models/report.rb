# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
# == Schema Information
# Schema version: 55
#
# Table name: reports
#
#  id             :integer(4)      not null, primary key
#  user_id        :integer(4)
#  subject        :string(255)
#  message        :string(255)
#  tag_id         :integer(4)
#  assessment_id  :integer(4)
#  created_at     :datetime
#  updated_at     :datetime
#  description_id :integer(4)
#

class Report < ActiveRecord::Base
end
