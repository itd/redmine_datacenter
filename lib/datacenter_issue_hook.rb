class DatacenterIssueHook < Redmine::Hook::ViewListener
  
  # Add our own elements to issue show view (in show and form sections)
  #
  # NB: This works too, maybe for future use if we have many things to 
  # do before rendering :
  #
  #   def view_issues_form_details_bottom(context)
  #     template = context[:controller].instance_variable_get("@template")
  #     template.render :partial => "datacenter_plugin/issue_form", :locals => {:context => context}
  #   end
  #
  render_on :view_issues_form_details_bottom, :partial => "datacenter_plugin/issue_form"
  render_on :view_issues_show_details_bottom, :partial => "datacenter_plugin/issue_show"
  
  # Add journal details for our Appli/Instance related to the current issues
  #
  def controller_issues_edit_before_save(context)
    #{:params => params, :issue => @issue, :time_entry => @time_entry, :journal => journal}
    app_before = context[:controller].instance_variable_get("@appli_instance_ids_before_change").sort
    if app_before
      app_after = context[:issue].appli_instance_ids.sort
      if app_after != app_before
        context[:journal].details << JournalDetail.new(:property => 'attr',
                                                       :prop_key => 'appli_instance_ids',
                                                       :old_value => app_before,
                                                       :value => app_after)
        context[:journal].save!
      end
    end
  end
  
  # Reformat journal details related to our Appli/Instance models
  #
  # Context: 
  # * :detail => Detail about de journal change
  # * :label  => Label for the current attribute
  # * :value  => New value for the current attribute
  # * :old_value => Old value for the current attribute
  #
  def helper_issues_show_detail_after_setting(context)
    #TODO: DRY it (see ApplisHelper)
    #TODO: optimize it: caching between multiple journals and between these two..
    d = context[:detail]
    if d.prop_key == 'appli_instance_ids'
      #Principle:
      # d.value = YAML.load(d.value.to_s)
      # d.value.map! do |a|
      #   type, id = a.split(":")
      #   Kernel.const_get(type).find(id).fullname
      # end.sort.join(", ")
      %w(value old_value).each do |key|
        d.send("#{key}=",YAML.load(d.send(key).to_s)) if d.send(key).is_a?(String) && d.send(key).match(/^---/)
        if d.send(key).respond_to?(:to_ary)
          d.send("#{key}=",d.send(key).map do |value|
            if value.match(/^(Appli|Instance):(\d+)$/)
              Kernel.const_get($~[1]).find($~[2]).fullname
            else
              value
            end
          end.sort.join(", "))
        end
      end
    end
  end
end
