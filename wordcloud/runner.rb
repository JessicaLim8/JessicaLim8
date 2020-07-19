##imports
require_relative "./readme_generator"
require_relative "./octokit_client"

class Runner
  ## constants
  MARKDOWN_PATH = 'README.md'
  REGEX_PATTERN = /\w[\w' ]+/

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
    word = split_input[1].downcase

    acknowledge_issue

    # TODO: Check if word is valid

    unless REGEX_PATTERN.match?(word)
      comment = "Sorry, your word was not valid. Please use valid alphanueric characters, spaces, apostrophes or underscores only"
      octokit.error_notification(reaction: 'confused', comment: comment)
    end

    # Create new word cloud
    generate_cloud(word)

    # write to readme
    write(word)
  end

  private

  def generate_cloud(word)
    `echo #{word} >> wordcloud/wordlist.txt`
    `wordcloud_cli --text wordcloud/wordlist.txt --imagefile wordcloud/wordcloud.png --prefer_horizontal 0.5 --repeat --fontfile wordcloud/Montserrat-Bold.otf --background white --colormask images/colourMask.jpg --width 700 --height 400 --regexp "#{REGEX_PATTERN}" --no_collocations --min_font_size 10 --max_font_size 120`
  end

  def write(word)
    message = "@#{@user} added '#{word}' to the Word Cloud"

    File.write(MARKDOWN_PATH, to_markdown)
    if @development
      puts message
    else
      # octokit.write_to_repo(
      #   filepath: MARKDOWN_PATH,
      #   message: message,
      #   sha: raw_markdown_data.sha,
      #   content: to_markdown,
      # )
      `git add README.md wordcloud/wordcloud.png wordcloud/wordlist.txt`
      `git diff`
      `git config --global user.email "github-action-bot@example.com"`
      `git config --global user.name "GitHub Action Bot"`
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
