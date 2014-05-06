# app/views/comments/create.rabl

collection @comment, :object_root => false
attributes :id, :uuid, :anonymized_user_id
attributes :updated_at_in_float => :updated_at