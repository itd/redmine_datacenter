class InstancesController < DatacenterPluginController
  before_filter :find_appli
  
  def new
    @instance = Instance.new
    @servers = Server.active
  end
  
  def create
    @instance = Instance.new(params[:instance])
    @servers = Server.active
    if @instance.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to appli_path(@project,@appli)
    else
      render :action => 'new'
    end
  end
  
  def edit
    @instance = Instance.find(params[:id])
    @servers = (Server.active + @instance.servers).uniq.sort_by(&:name)
  end
  
  def update
    @instance = Instance.find(params[:id])
    @servers = (Server.active + @instance.servers).uniq.sort_by(&:name)
    if @instance.update_attributes(params[:instance])
      flash[:notice] = l(:notice_successful_update)
      redirect_to appli_path(@project,@appli)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @instance = Instance.find(params[:id])
    @instance.status = Instance::STATUS_LOCKED
    @instance.save
    redirect_to appli_path(@project,@appli)
  end

  private
  def find_appli
    begin
      @appli = Appli.find(params[:appli_id],
                          :conditions => {:datacenter_id => @datacenter})
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end
end
