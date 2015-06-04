require_dependency "hubstats/application_controller"

module Hubstats
  class DeploysController < ApplicationController

    def index
      deploy_id = Hubstats::Deploy
        .belonging_to_repos(params[:repo])
        .map(&:id)
      #  .order_with_timespan(@timespan, "ASC")
      #  .belonging_to_users(params[:users])
      #  .belonging_to_repos(params[:repo])
      #  .has_many_pull_requests(params[:pull_requests])

      # sets to include user and repo, and sorts data
      @deploys = Hubstats::Deploy.includes(:repo).includes(:pull_requests)
        .order_with_timespan(@timespan, params[:order])
        .group_by(params[:group])
        .paginate(:page => params[:page], :per_page => 15)
      #  .belonging_to_users(params[:users]).belonging_to_repos(params[:repos])

      if params[:group] == "user"
        @groups = @deploys.to_a.group_by(&:user_name)
      elsif params[:group] == "repo"
        @groups = @deploys.to_a.group_by(&:repo_name)
      else
        @groups = nil
      end
    end

    def show
      @deploy = Hubstats::Deploy.find(params[:id])
      @repo = @deploy.repo
      @pull_requests = Hubstats::PullRequest.belonging_to_deploy(@deploy.id)
      #@pull_request_count = Hubstats::PullRequest.where(deploy_id: params[:id]).additions.belonging_to_pull_request(params[:id]).includes(:user).created_since(@timespan).count(:all)
      # @stats = {
        #pull_request_count: @pull_request_count,
        #net_additions: @pull_request.additions.to_i - @pull_request.deletions.to_i
      # }
    end

    def create
      if params[:deployed_by].nil? || params[:git_revision].nil? || params[:repo_name].nil?
        render text: "Missing a necessary parameter: deployer, git revision, or repository name.", :status => 400 and return
      else
        @deploy = Deploy.new
        @deploy.deployed_at = params[:deployed_at]
        @deploy.deployed_by = params[:deployed_by]
        @deploy.git_revision = params[:git_revision]
        @repo = Hubstats::Repo.where(full_name: params[:repo_name])
        
        if @repo.empty?
          render text: "Repository name is invalid.", :status => 400 and return
        else
          @deploy.repo_id = @repo.first.id.to_i
        end

        @pull_request_id_array = params[:pull_request_ids].split(",").map {|i| i.strip.to_i}
        @deploy.pull_requests = Hubstats::PullRequest.where(repo_id: @deploy.repo_id)
                                                     .where(number: @pull_request_id_array)

        if @deploy.save
          render :nothing =>true, :status => 200 and return
        else
          render :nothing => true, :status => 400 and return
        end
      end
    end
  end
 end
