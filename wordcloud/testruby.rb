location = `which wordcloud_cli`
puts location
`wordcloud_cli --text wordlist.txt --imagefile wordcloud.png --prefer_horizontal 0.5 --repeat --regex #{REGEX_PATTERN} --fontfile /Users/jessica/Library/Fonts/Montserrat-Bold.otf --background white --colormask ../images/gradient.jpg --width 700 --height 400 --no_collocations --min_font_size 10 --max_font_size 120`
