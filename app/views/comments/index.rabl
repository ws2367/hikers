# app/views/comments/index.rabl

collection @comments, :root => "Comment", :object_root => false
attributes :id, :uuid, :content, :anonymized_user_id
attributes :updated_at_in_float => :updated_at
attributes :post_uuid => :post_uuid