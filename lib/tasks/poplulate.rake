namespace :db do

	desc "Fill database with sample data"
	task populate: :environment do

		10.times do |n|
			puts "[DEBUG} creating user #{n+1} of 10"
			name = Faker::Name.name
			email = "user-#{n+1}@example.com"
			password = "password"
			User.create!(	name: name,
						 	email: email,
						 	password: password,
						 	password_confirmation: password )

		end

	puts "Now we gonna add locations, institutions, entities, posts and comments!"

	10.times do |n|
		name = Faker::Address.state
		@loc = Location.create!(name: name)
		
		10.times do |m|
			name = Faker::Company.name
			@inst = @loc.institutions.create!(name: name)

			

			User.all.each do |user|
				name = Faker::Name.name
				@ent = user.entities.create!(name: name,
					                 institution_id: @inst.id)


				content = Faker::Lorem.paragraph
				@post = @ent.posts.create!(content: content,
						                   user_id: user.id)
						                   #:status => true)

				@comment = @post.comments.create!(content: content,
												  user_id: user.id)
												  #:status =>  true)
			end
		end
	end

	puts "Now we gonna add likes, hates, views and follows!"

@lastUser = User.last
			User.all.each do |user|

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
				@lastUser = user
			end

=begin
		10.times do |n|
			puts "[DEBUG} creating user #{n+1} of 10"
			name = Faker::Name.name
			email = "user-#{n+1}@example.com"
			password = "password"
			User.create!(	name: name,
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
=end
	end
end
