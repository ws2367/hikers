# app/views/posts/index.rabl


collection @posts, :root => "Post", :object_root => false
attributes :id, :uuid, :content, :popularity, :followers_count, :comments_count
attributes :created_at_in_float => :updated_at

node(:is_yours) { |post| (@user_id == post.user_id) }
node(:following) {|post| post.is_followed_by(@user_id)}

child :entities, :object_root => false do
  attributes :id, :name, :fb_user_id, :institution, :location
  attributes :created_at_in_float => :updated_at

  node(:is_your_friend) { |entity| entity.is_friend_of_user(@user_id) }
end