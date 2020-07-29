##imports
require_relative "./readme_generator"
require_relative "./octokit_client"

class Runner
  ## constants
  MARKDOWN_PATH = 'README.md'
  REGEX_PATTERN = /\w[\w' ]+/
  ADDWORD = 'add'
  SHUFFLECLOUD = 'shuffle'

  def initialize(
    github_token:,
    issue_number:,
    issue_title:,
    repository: "JessicaLim8/JessicaLim8",
    user:,
    development: false
  )
    @github_token = github_token
    @repository = repository
    @issue_number = issue_number
    @issue_title = issue_title
    @user = user
    @development = development
  end

  def run
    split_input = @issue_title.split('|')
    command = split_input[1]
    word = split_input[2]

    acknowledge_issue

    if command == SHUFFLECLOUD && word.nil?
      generate_cloud
      message = "@#{@user} regenerated the Word Cloud"
    elsif command == ADDWORD
      word = add_to_wordlist(word)
      generate_cloud
      message = "@#{@user} added '#{word}' to the Word Cloud"
      # write to readme
    else
      comment = "Sorry, the command 'wordcloud|#{command}' is not valid.%0APlease try 'wordcloud|add|your-word' or 'wordcloud|shuffle'"
      octokit.error_notification(reaction: 'confused', comment: comment)
    end

    write(message)

  rescue StandardError => e
    comment = "There seems to be an error. Sorry about that."
    octokit.error_notification(reaction: 'confused', comment: comment, error: e)
  end

  private
  def add_to_wordlist(word)
    #Check valid word
    invalid_word_error if word.nil?
    if word[REGEX_PATTERN] != word
      if word[REGEX_PATTERN] == word[1..-2] && word[1..-2].length > 2 && word[0] == "<" && word[-1] == ">"
        word = word[1..-2].downcase
      else
        invalid_word_error
      end
    end

    # Check for spaces
    word = word.gsub("_", " ")
    # Add word to list
    `echo #{word} >> wordcloud/wordlist.txt`
    word
  end

  def invalid_word_error
    # Invalid expression, did not pass regex
    comment = "Sorry, your word was not valid. Please use valid alphanueric characters, spaces, apostrophes or underscores only"
    octokit.error_notification(reaction: 'confused', comment: comment)
  end

  def generate_cloud
    # Create new word cloud
    result = system('sort -R wordcloud/wordlist.txt | wordcloud_cli --imagefile wordcloud/wordcloud.png --prefer_horizontal 0.5 --repeat --fontfile wordcloud/Montserrat-Bold.otf --background white --colormask images/colourMask.jpg --width 700 --height 400 --regexp "\w[\w\' ]+" --no_collocations --min_font_size 10 --max_font_size 120')
    # Failed cloud generation
    unless result
      comment = "Sorry, something went wrong... the word cloud did not update :("
      octokit.error_notification(reaction: 'confused', comment: comment)
    end
    result
  end

  def write(message)
    File.write(MARKDOWN_PATH, to_markdown)
    if @development
      puts message
    else
      `git add README.md wordcloud/wordcloud.png wordcloud/wordlist.txt`
      `git diff`
      `git config --global user.email "github-action-bot@example.com"`
      `git config --global user.name "github-actions[bot]"`
      `git commit -m "#{message}" -a || echo "No changes to commit"`
      `git push`
      octokit.add_reaction(reaction: 'rocket')
    end
  end

  def to_markdown
    ReadmeGenerator.new(octokit: octokit).generate
  end

  def acknowledge_issue
    octokit.add_label(label: 'wordcloud')
    octokit.add_reaction(reaction: 'eyes')
    octokit.close_issue
  end

  def raw_markdown_data
    @raw_markdown_data ||= octokit.fetch_from_repo(MARKDOWN_PATH)
  end

  def octokit
    @octokit ||= OctokitClient.new(github_token: @github_token, repository: @repository, issue_number: @issue_number)
  end
end
