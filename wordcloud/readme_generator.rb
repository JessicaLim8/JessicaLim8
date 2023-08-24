require_relative "./cloud_types"

class ReadmeGenerator
  WORD_CLOUD_URL = 'https://raw.githubusercontent.com/JessicaLim8/JessicaLim8/master/wordcloud/wordcloud.png'
  ADDWORD = 'add'
  SHUFFLECLOUD = 'shuffle'
  INITIAL_COUNT = 3
  USER = "JessicaLim8"

  def initialize(octokit:)
    @octokit = octokit
  end

  def generate
    participants = Hash.new(0)
    current_contributors = Hash.new(0)
    current_words_added = INITIAL_COUNT
    total_clouds = CloudTypes::CLOUDLABELS.length
    total_words_added = INITIAL_COUNT * total_clouds

    octokit.issues.each do |issue|
      participants[issue.user.login] += 1
      if issue.title.split('|')[1] != SHUFFLECLOUD && issue.labels.any? { |label| CloudTypes::CLOUDLABELS.include?(label.name) }
        total_words_added += 1
        if issue.labels.any? { |label| label.name == CloudTypes::CLOUDLABELS.last }
          current_words_added += 1
          current_contributors[issue.user.login] += 1
        end
      end
    end

    markdown = <<~HTML
# Hi I'm Jessica 👋

[![Linkedin Badge](https://img.shields.io/badge/-jlim-blue?style=flat&logo=Linkedin&logoColor=white&link=https://www.linkedin.com/in/jlim/)](https://www.linkedin.com/in/jlim/)
[![Medium Badge](https://img.shields.io/badge/-@jessicalim-000000?style=flat&labelColor=000000&logo=Medium&link=https://medium.com/@jessicalim)](https://medium.com/@jessicalim)
[![Website Badge](https://img.shields.io/badge/-jessicalim.me-47CCCC?style=flat&logo=Google-Chrome&logoColor=white&link=https://jessicalim.me)](https://jessicalim.me)
[![Twitter Badge](https://img.shields.io/badge/-@__jesslim-1ca0f1?style=flat&labelColor=1ca0f1&logo=twitter&logoColor=white&link=https://twitter.com/_jesslim)](https://twitter.com/_jesslim)
[![Instagram Badge](https://img.shields.io/badge/-@__jessicaalim-purple?style=flat&logo=instagram&logoColor=white&link=https://instagram.com/_jessicaalim/)](https://instagram.com/_jessicaalim)
[![Gmail Badge](https://img.shields.io/badge/-jessicalim813-c14438?style=flat&logo=Gmail&logoColor=white&link=mailto:jessicalim813@gmail.com)](mailto:jessicalim813@gmail.com)

Welcome to my profile! I am a Canadian :Canada: working in Hong Kong. I spend my time developing tech to help Olympic athletes, [writing](https://medium.com/@_jessicalim), and hiking :seedling:. I have previously PM'd @Autodesk, SWE'd @Microsoft & @Wealthsimple, and UX&D consulted @Deloitte. Thanks for visiting and I'd love to [connect](https://www.linkedin.com/in/jlim/)!


## Join the Community Word Cloud :cloud: :pencil2:

![](https://img.shields.io/badge/Words%20Added-#{total_words_added}-brightgreen?labelColor=7D898B)
![](https://img.shields.io/badge/Word%20Clouds%20Created-#{total_clouds}-48D6FF?labelColor=7D898B)
![](https://img.shields.io/badge/Total%20Participants-#{participants.size}-AC6EFF?labelColor=7D898B)

### :thought_balloon: [Add a word](https://github.com/JessicaLim8/JessicaLim8/issues/new?template=addword.md&title=wordcloud%7C#{ADDWORD}%7C%3CINSERT-WORD%3E) to see the word cloud update in real time :rocket:

A new word cloud will be automatically generated when you [add your own word](https://github.com/JessicaLim8/JessicaLim8/issues/new?template=addword.md&title=wordcloud%7C#{ADDWORD}%7C%3CINSERT-WORD%3E). The prompt will change frequently, so be sure to come back and check it out :relaxed:

:star2: Don't like the arrangement of the current word cloud? [Regenerate it](https://github.com/JessicaLim8/JessicaLim8/issues/new?template=shufflecloud.md&title=wordcloud%7C#{SHUFFLECLOUD}) :game_die:

<div align="center">

## #{CloudTypes::CLOUDPROMPTS.last}

<img src="#{WORD_CLOUD_URL}" alt="WordCloud" width="100%">

![Word Cloud Words Badge](https://img.shields.io/badge/Words%20in%20this%20Cloud-#{current_words_added}-informational?labelColor=7D898B)
![Word Cloud Contributors Badge](https://img.shields.io/badge/Contributors%20this%20Cloud-#{current_contributors.size}-blueviolet?labelColor=7D898B)

    HTML

    # TODO: [![Github Badge](https://img.shields.io/badge/-@username-24292e?style=flat&logo=Github&logoColor=white&link=https://github.com/username)](https://github.com/username)

    current_contributors.each do |username, count|
      markdown.concat("[![Github Badge](https://img.shields.io/badge/-@#{format_username(username)}-24292e?style=flat&logo=Github&logoColor=white&link=https://github.com/#{username})](https://github.com/#{username}) ")
    end

    markdown.concat("\n\n Check out the [previous word cloud](#{previous_cloud_url}) to see our community's **#{CloudTypes::CLOUDPROMPTS[-2]}**")

    markdown.concat("</div>")

    markdown.concat("\n\n ### Need inspiration for your own README? Check out [How to Stand out on GitHub using Profile READMEs](https://medium.com/better-programming/how-to-stand-out-on-github-with-profile-readmes-dfd2102a3490?source=friends_link&sk=61df9c4b63b329ad95528b8d7c00061f)")
  end

  private

  def format_username(name)
    name.gsub('-', '--')
  end

  def previous_cloud_url
    url_end = CloudTypes::CLOUDPROMPTS[-2].gsub(' ', '-').gsub(':', '').gsub('?', '').downcase
    "https://github.com/JessicaLim8/JessicaLim8/blob/master/previous_clouds/previous_clouds.md##{url_end}"
  end

  attr_reader :octokit
end
