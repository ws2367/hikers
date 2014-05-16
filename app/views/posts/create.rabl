# app/views/posts/create.rabl

#collection @posts, :root => "Post", :object_root => false
#attributes :id, :uuid
#attributes :created_at_in_float => :updated_at

object false

child @posts => "Post" do
  #collection favourite_groups
  #extends 'favourites/base'
  attributes :id, :uuid, :popularity
  attributes :created_at_in_float => :updated_at
end

child @entities, :root=>"Entity", :object_root => false do
  attributes :id, :fb_user_id
  attributes :created_at_in_float => :updated_at
end

# collection @entities, :root => "Entity", :object_root => false
# attributes :id

# attributes :uuid => :uuid, :if => lambda { |ent| ent.uuid_c == nil}
# attributes :uuid => :uuid_s, :uuid_c => :uuid, :if => lambda { |ent| ent.uuid_c != nil}


# attributes :created_at_in_float => :updated_at