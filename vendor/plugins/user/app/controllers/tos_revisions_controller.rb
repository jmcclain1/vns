class TosRevisionsController < ApplicationController

  before_filter :login_required
  around_filter :secure_using_logged_in_user
  
  def index
    @tos_revisions = TermsOfService.find(:all, :order => "revision DESC")
  end

  def can_show?
    logged_in_user.super_admin?
  end

  def show
    @tos_revision = TermsOfService.find(params[:id])
  end
  
  def new
    @tos_revision = TermsOfService.new
  end
  
  def create
    @tos_revision = TermsOfService.new(params[:tos_revision])
    
    if @tos_revision.save
      flash[:notice] = 'Terms of Service has been created.'.customize
      redirect_to tos_revisions_path
    else
      render :action => "new"
    end
  end
  
end