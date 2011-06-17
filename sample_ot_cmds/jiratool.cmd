setup do
    require 'jira4r/jira4r'
    jirahost = @options[:jirahost] || "http://jira.atlassian.com"
puts "jirahost: #{jirahost}"
    @jira = Jira4R::JiraTool.new(2, jirahost)
    @jira.log_level=4
    unless @options[:username].nil? or @options[:password].nil?
        @jira.login(@options[:username], @options[:password])
    end
end

command :get_projects, "list all top level project namespaces" do
    @jira.getProjectsNoSchemes().each { |proj| puts proj.name }
    return self
end

command :get_components, "get a list of all components within a project" do |project|
    @jira.getComponents(project).each { |comp| puts comp.name }
    return self
end

command :get_versions, "list all issues under a specific project" do |project|
    @jira.getVersions(project).each { |version| puts version.name }
    return self
end

command :get_issues_list, "get a list of all issues under a specific fix version" do |version|
    @jira.getIssuesFromJqlSearch("fixVersion='#{version}'", 999).each { |issue| puts issue.key}
    return self
end

command :get_issue, "retrieve a specific issue" do |issue|
    issue = @jira.getIssue(issue)
    puts "issue: #{issue.key}"
    puts "jira_id: #{issue.id}"
    puts "reporter: #{issue.reporter}"
    puts "assignee: #{issue.assignee}"
    puts "created: #{issue.created.to_s}"
    puts "updated: #{issue.updated.to_s}"
    puts "duedate: #{issue.duedate.to_s}"
    puts "project: #{issue.project}"
    puts "environment: #{issue.environment}"
    puts "affectsversion: #{issue.affectsVersions[0].name}"
    puts "fixversion: #{issue.fixVersions[0].name}"
    puts "priority: #{issue.priority}"
    puts "branch: #{issue.customFieldValues[0].values}"
    puts "status: #{issue.status}"
    puts "description: '#{issue.description}'"
    return self
end

command :get_branch, "show the branch name from the issue" do |issue|
    issue = @jira.getIssue(issue)
    puts issue.customFieldValues[0].values
    return self
end

option :u, :user
option :p, :password
option :j, :jirahost
