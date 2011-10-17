# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
class ReportAbuseMailer < ActionMailer::Base
  
  def report_abuse(subject, message, recipients, from)
    mail(:subject => subject, :from => from, :to => recipients.join(", ")) do |format|
      format.text { render :text => message }
    end
  end

  def notify_abuser(subject, message, recipients, from)
    mail(:subject => subject, :from => from, :to => recipients.join(", ")) do |format|
      format.text { render :text => message }
    end
  end
end


