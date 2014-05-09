namespace :post do

  POPULARITY_BASE = 1396310400
  desc "Update popularity"
  task :update, [] => :environment do

    puts "[DEBUG] Will change popularities in posts!"
    Post.all.each do |post|

      # tc + tp + nc * 300 + nf * 150
      tc = (post.comments.empty? ? post.created_at.to_f : post.comments.last.created_at.to_f) - POPULARITY_BASE
      tp = (post.created_at.to_f) - POPULARITY_BASE
      nc = post.comments.count
      nf = post.follows.count
      new_popularity = tc + tp + nc * 300 + nf * 150

      post.update_attribute("popularity", new_popularity)
      puts "[DEBUG] The popularity of Post #{post.id} is #{new_popularity}"
    end

  end
end