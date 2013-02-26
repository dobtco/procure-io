xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0" do
  xml.channel do
    xml.title "Project Listings"
    xml.description "Project listings on Procure.io."
    xml.link projects_url(@filter_params)

    for project in @projects
      xml.item do
        xml.title project.title
        xml.description project.abstract
        xml.pubDate project.posted_at.to_s(:rfc822)
        xml.link project_url(project)
        xml.guid project_url(project)
      end
    end
  end
end