# To Decidim v0.23
Debates and Comments have been added to the global search and need to be indexed, otherwise all previous content won't be available as search results. You should run this in a Rails console at your server or create a migration to do it.

Please be aware that it could take a while if your database has a lot of content.
```ruby
Decidim::Comments::Comment.find_each(&:try_update_index_for_search_resource)
Decidim::Debates::Debate.find_each(&:try_update_index_for_search_resource)
```

# To Decidim v0.21


# From Decidim v0.19 to v0.20
Due to #5469, in order for the newly searchable entities to be indexed, you'll have to manually trigger a reindex. You can do that by running in the rails console:

```ruby
Decidim::Assembly.find_each(&:add_to_index_as_search_resource)
Decidim::ParticipatoryProcess.find_each(&:add_to_index_as_search_resource)
Decidim::Conference.find_each(&:add_to_index_as_search_resource)
Decidim::Consultation.find_each(&:add_to_index_as_search_resource)
Decidim::Initiative.find_each(&:add_to_index_as_search_resource)
Decidim::Debates::Debate.find_each(&:add_to_index_as_search_resource)
# results are ready to be searchable but don't have a card-m so can't be rendered
# Decidim::Accountability::Result.find_each(&:add_to_index_as_search_resource)
Decidim::Budgets::Project.find_each(&:add_to_index_as_search_resource)
Decidim::Blogs::Post.find_each(&:add_to_index_as_search_resource)
```
