# Title: PostCollation
# Description: Module that adds a method to collate posts by date

module PostCollation
  def collate(posts)
    collated_posts = {}

    posts.reverse.each do |post|
      y, m, d = post.date.year, post.date.month, post.date.day

      collated_posts[ y ] = {} unless collated_posts.key? y
      collated_posts[ y ][ m ] = {} unless collated_posts[y].key? m
      collated_posts[ y ][ m ][ d ] = [] unless collated_posts[ y ][ m ].key? d
      collated_posts[ y ][ m ][ d ].push(post) unless collated_posts[ y ][ m ][ d ].include?(post)
    end

    collated_posts
  end
end
