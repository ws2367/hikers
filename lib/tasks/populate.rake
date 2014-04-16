require 'csv'

namespace :db do

    desc "Fill UUIDs for each fake data"
    task uuid: :environment do
        # Entity.all.each do |entity|
        #     entity.update_attribute("uuid", UUIDTools::UUID.random_create.to_s) unless entity.uuid
        # end
        Post.all.each do |post|
            post.update_attribute("uuid", UUIDTools::UUID.random_create.to_s) unless post.uuid
        end
        Comment.all.each do |comment|
            comment.update_attribute("uuid", UUIDTools::UUID.random_create.to_s) unless comment.uuid
        end
    end


    desc "Fill database with sample data"
    task populate: :environment do
        fb_user_id = 1131095462 # MY FB id......
        puts "[DEBUG] creating user with fb id #{fb_user_id}"
        begin
            User.create!(fb_user_id: fb_user_id, :fb_access_token=>"test")
        rescue
            puts "[CAUTION] failed in creating user!"
        end
        
        
        puts "[DEBUG] Now we gonna add entities, posts and comments!"

        counter = 1
        
        User.all.each do |user|
          10.times do |n|
            name = Faker::Name.name
            @ent = user.entities.create!(name: name,
                                         institution: Faker::Company.name,
                                         location: Faker::Address.state,
                                         uuid: UUIDTools::UUID.random_create.to_s)

            Friendship.create!(user_id: user.id, entity_id: @ent.id) if rand(2)
            end
        end

        @entity_num = Entity.count
        
        User.all.each do |user|
          10.times do |n|
            content = "Post " + counter.to_s + " While the announcement appeared to end hopes of finding survivors more than two weeks after the flight vanished, it left many key questions unanswered, including what went wrong aboard."
            counter += 1

            max_entity_num = (@entity_num / 1.5).to_i
            entity_ids = Entity.all.collect{|ent| ent.id}.to_a.shuffle[1, rand(max_entity_num - 1) + 1]
            entities = Entity.find(entity_ids)

            @post = Post.create!(content: content, 
                                 user_id: user.id,
                                 uuid: UUIDTools::UUID.random_create.to_s)
            
            entities.each { |entity|
              Connection.create!(post_id: @post.id, entity_id: entity.id)
            }

            @comment = @post.comments.create!(content: "comment 1",
                                              user_id: user.id,
                                              uuid: UUIDTools::UUID.random_create.to_s)

            @comment = @post.comments.create!(content: "comment 2",
                                                user_id: user.id,
                                                uuid: UUIDTools::UUID.random_create.to_s)
          end
        end
        
    end

=begin 
    desc "Fill database with sample data"
    task populate: :environment do

        10.times do |n|
            puts "[DEBUG] creating user #{n+1} of 10"
            name = Faker::Name.name
            # email = "user-#{n+1}@example.com"
            password = "password"
            User.create!(    user_name: name,
                             #email: email,
                             password: password,
                             password_confirmation: password )

        end

    puts "[DEBUG] Now we gonna add locations, institutions, entities, posts and comments!"

    10.times do |n|
        name = Faker::Address.state
        @loc = Location.create!(name: name)
        puts "[DEBUG] creating location #{n+1} of 10"

        10.times do |m|
            name = Faker::Company.name
            @inst = @loc.institutions.create!(name: name)

            User.all.each do |user|
                name = Faker::Name.name
                @ent = user.entities.create!(name: name,
                                     institution_id: @inst.id, 
                                     positions: [ [Faker::Address.latitude, Faker::Address.longitude],
                                                     [Faker::Address.latitude, Faker::Address.longitude],
                                                     [Faker::Address.latitude, Faker::Address.longitude]
                                        ])


                content = Faker::Lorem.paragraph

                @post = @ent.posts.create!(content: content, user_id: user.id)
                Connection.create!(post_id: @post.id, entity_id: @ent.prev.id)

                @comment = @post.comments.create!(content: content,
                                                  user_id: user.id)
                                                  #:status =>  true)
            end
        end
    end


    puts "[DEBUG] Now we gonna add likes, hates, views, follows and shares!"

@lastUser = User.last
            User.all.each do |user|
			
				puts "[DEBUG] User #{user.id} of 10 is creating"

                user.likes.create!(likee_id: @lastUser.entities.first.id,
                                   likee_type: "Entity")
                user.likes.create!(likee_id: @lastUser.posts.first.id,
                                   likee_type: "Post")
                user.likes.create!(likee_id: @lastUser.comments.first.id,
                                   likee_type: "Comment")
                
                user.hates.create!(hatee_id: @lastUser.entities.first.id,
                                   hatee_type: "Entity")
                user.hates.create!(hatee_id: @lastUser.posts.first.id,
                                   hatee_type: "Post")
                user.hates.create!(hatee_id: @lastUser.comments.first.id,
                                   hatee_type: "Comment")

                user.follows.create!(followee_id: @lastUser.entities.first.id,
                                     followee_type: "Entity")
                user.follows.create!(followee_id: @lastUser.posts.first.id,
                                     followee_type: "Post")

                user.views.create!(viewee_id: @lastUser.entities.first.id,
                                   viewee_type: "Entity")
                user.views.create!(viewee_id: @lastUser.posts.first.id,
                                   viewee_type: "Post")
                

                user.shares.create!(sharee_id: @lastUser.entities.first.id,
                                    sharee_type: "Entity",
                                    numbers: [Faker::PhoneNumber.phone_number,
                                    	      Faker::PhoneNumber.phone_number,
                                    	      Faker::PhoneNumber.phone_number
                                    	     ]
                                   )
                
                user.shares.create!(sharee_id: @lastUser.posts.first.id,
                                    sharee_type: "Post",
                                    numbers: [Faker::PhoneNumber.phone_number,
                                    	      Faker::PhoneNumber.phone_number,
                                    	      Faker::PhoneNumber.phone_number
                                    	     ]
                                   )

                @lastUser = user
            end
=end
=begin
        10.times do |n|
            puts "[DEBUG} creating user #{n+1} of 10"
            name = Faker::Name.name
            email = "user-#{n+1}@example.com"
            password = "password"
            User.create!(    name: name,
                             email: email,
                             password: password,
                             password_confirmation: password )

        end
=end
=begin
        User.all.each do |user|
            puts "[DEBUG] uploading images for user #{user.id} of #{User.last.id}"
            10.times do |n|
                image = File.open(Dir.glob(File.join(Rails.root, 'sampleimages', '*')).sample)
                description = %w(cool awesome crazy wow adorable incredible).sample
                user.pins.create!(image: image, description: description)
            end
        end
    end
=end
end
