class ApiAccountsController < ApplicationController

  def index
    @api_account       = ApiAccount.new
    @api_accounts      = current_user.api_accounts
    @github_accounts   = @api_accounts.where(api_id: Api.find_by(provider: "Github").id)
    @fitbit_accounts   = @api_accounts.where(api_id: Api.find_by(provider: "Fitbit").id)
    @exercism_accounts = @api_accounts.where(api_id: Api.find_by(provider: "Exercism").id)
    @duolingo_accounts = @api_accounts.where(api_id: Api.find_by(provider: "Duolingo").id)
    @github_api_id     = Api.find_by(provider: "Github").id
    @fitbit_api_id     = Api.find_by(provider: "Fitbit").id
    @exercism_api_id   = Api.find_by(provider: "Exercism").id
    @duolingo_api_id   = Api.find_by(provider: "Duolingo").id
  end

  def create
    api_account_data           = api_account_params
    api_account_data[:user_id] = current_user.id
    new_account                = ApiAccount.find_or_create_by(api_account_data)
    if new_account.api_account_exists
      new_account.save
      flash[:success] = "Added API Account"
      redirect_to :back
    else
      flash[:error] = "Username is Not Valid"
      redirect_to :back
    end
  end

  def show
    @api_account = current_user.api_accounts.where(id: params[:id]).first
    if @api_account
      @provider        = @api_account.api.provider.downcase
      @username        = @api_account.api_username
      @api_request     = ApiRequest.new(@username, @provider)
      @streak          = @api_account.streak
      @year_percentage = @api_request.get_percentage_days_commited_this_year
      @this_year       = @api_request.get_this_years_total_commits
      @goals = @api_account.goals
    else
      redirect_to dashboard_path
    end
  end

  private

  def api_account_params
    params.require(:api_account).permit(:id, :api_id, :api_username)
  end

end
