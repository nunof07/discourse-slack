# name: Slack
# about: Displays member and channel information from Slack in a header dropdown
# version: 0.1.0
# authors: Nuno Freitas (nunofreitas@gmail.com)
# url: https://github.com/nunof07/discourse-slack

register_asset "stylesheets/slack.scss"

enabled_site_setting :slack_enabled

SLACK_PLUGIN_NAME ||= "slack".freeze

after_initialize do
    module ::Slack
        class Engine < ::Rails::Engine
            engine_name SLACK_PLUGIN_NAME
            isolate_namespace Slack
        end
    end
    
    Slack::Engine.routes.draw do
        get  "/list"    => "slack#list"
        get  "/team"    => "slack#team"
    end
    
    Discourse::Application.routes.append do
        mount ::Slack::Engine, at: "/slack"
    end
    
    require_dependency "application_controller"
    
    class ::Slack::SlackController < ::ApplicationController
        requires_plugin SLACK_PLUGIN_NAME
        
        rescue_from 'StandardError' do |e| render_json_error e.message end
        
        # get a json object with an array of members
        def list
            result = { :members => [] }
            membersResponse = get_response("users.list", { :presence => 1 })
            
            if membersResponse["ok"]
                memberChannels = {}
                
                unless membersResponse["members"].empty?
                    # get channel information
                    channelsResponse = get_response("channels.list", { :exclude_archived => 1 })
                    
                    if channelsResponse["ok"]
                        channelsResponse["channels"].each { |channel|
                            channel["members"].each { |memberId|
                                unless memberChannels.key?(memberId)
                                    memberChannels[memberId] = []
                                end
                                
                                memberChannels[memberId].push(channel["name"])
                            }
                        }
                    end
                end
                
                # build result
                membersResponse["members"].each { |member|
                    unless member["deleted"] || member["is_bot"]
                        if member["presence"] == "active" || SiteSetting.slack_away
                            memberResult = {
                                :name => member["name"],
                                :presence => member["presence"],
                                :channels => [],
                            }
                            
                            if memberChannels.key?(member["id"])
                                memberResult[:channels] = memberChannels[member["id"]]
                                memberResult[:channels].sort!
                            end
                            
                            result[:members].push(memberResult)
                        end
                    end
                }
                result[:members].sort! { |left, right| left[:name] <=> right[:name] }
            end
            
            render json: result
        end
        
        # get a json object with the team info from Slack
        def team
            result = get_response("team.info")
            
            unless result.empty?
                result = {
                    :name => result["team"]["name"],
                    :url => "https://#{result["team"]["domain"]}.slack.com"
                }
            end
            
            render json: result
        end
        
        private
            
            # get a json response from Slack Web API
            def get_response(path, params = {})
                if SiteSetting.slack_endpoint.to_s == '' || SiteSetting.slack_token.to_s == ''
                    result = {}
                else
                    params[:token] = SiteSetting.slack_token
                    query = params.collect { |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&')
                    uri = URI.parse("#{SiteSetting.slack_endpoint}#{path}?#{query}")
                    response = Net::HTTP.get_response(uri)
                    result = JSON.parse(response.body)
                end
                
                result
            end
    end
end
