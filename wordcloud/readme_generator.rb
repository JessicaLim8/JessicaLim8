class ReadmeGenerator
  WORD_CLOUD_URL = 'https://raw.githubusercontent.com/JessicaLim8/JessicaLim8/master/wordcloud/wordcloud.png'
  ADDWORD = 'add'
  SHUFFLECLOUD = 'shuffle'
  CLOUDTYPES = ['quarantine']

  def initialize(octokit:)
    @octokit = octokit
  end

  def generate
    participants = Hash.new(0)
    current_contributors = Hash.new(0)
    total_words_added = 0
    current_words_added = 0
    total_clouds = CLOUDTYPES.length

    octokit.issues.each do |issue|
      participants[issue.user.login] += 1
      if issue.title.split('|')[1] != SHUFFLECLOUD && issue.labels.any? { |label| CLOUDTYPES.include?(label.name) }
        total_words_added += 1
        if issue.labels.any? { |label| label.name == CLOUDTYPES.last }
          current_words_added += 1
          current_contributors[issue.user.login] += 1
        end
      end
    end

    markdown = <<~HTML
      # Hi I'm Jessica 👋
      [![Linkedin Badge](https://img.shields.io/badge/-jlim-blue?style=flat&logo=Linkedin&logoColor=white&link=https://www.linkedin.com/in/jlim/)](https://www.linkedin.com/in/jlim/)
      [![Medium Badge](https://img.shields.io/badge/-@__jessicalim-000000?style=flat&labelColor=000000&logo=Medium&link=https://medium.com/@_jessicalim)](https://medium.com/@_jessicalim)
      [![Website Badge](https://img.shields.io/badge/-jessicalim.me-47CCCC?style=flat&logo=Google-Chrome&logoColor=white&link=https://jessicalim.me)](https://jessicalim.me)
      [![Twitter Badge](https://img.shields.io/badge/-@__jesslim-1ca0f1?style=flat&labelColor=1ca0f1&logo=twitter&logoColor=white&link=https://twitter.com/_jesslim)](https://twitter.com/_jesslim)
      [![Instagram Badge](https://img.shields.io/badge/-@jlim__slam-purple?style=flat&logo=instagram&logoColor=white&link=https://instagram.com/jlim_slam/)](https://instagram.com/jlim_slam)
      [![Gmail Badge](https://img.shields.io/badge/-jessicalim813-c14438?style=flat&logo=Gmail&logoColor=white&link=mailto:jessicalim813@gmail.com)](mailto:jessicalim813@gmail.com)

      Welcome to my profile! I'm a student interning @Microsoft, an aspiring [writer](https://medium.com/@_jessicalim), part-time coder and full-time adventure seeker. Thanks for visiting and I'd love to [connect](https://www.linkedin.com/in/jlim/)!


      ## Join the Community Word Cloud :cloud: :pencil2:

      ![](https://img.shields.io/badge/Words%20Added-#{total_words_added}-brightgreen?labelColor=7D898B)
      ![](https://img.shields.io/badge/Word%20Clouds%20Created-#{total_clouds}-48D6FF?labelColor=7D898B)
      ![](https://img.shields.io/badge/Total%20Participants-#{participants.size}-AC6EFF?labelColor=7D898B)

      ### :thought_balloon: [Add a word](https://github.com/JessicaLim8/JessicaLim8/issues/new?title=wordcloud%7C#{ADDWORD}%7C%3Cinsert-word%3E&body=Just+replace+%3Cinsert-word%3E+with+your+word!%0D%0ANext+click+%27Submit+new+issue%27) to see the word cloud update in real time :rocket:

      A new word cloud will be automatically generated when you [add your own word](https://github.com/JessicaLim8/JessicaLim8/issues/new?title=wordcloud%7C#{ADDWORD}%7C%3Cinsert-word%3E&body=Just+replace+%3Cinsert-word%3E+with+your+word!%0D%0ANext+click+%27Submit+new+issue%27). The prompt will change frequently, so be sure to come back and check it out :relaxed:

      :star2: Don't like the arrangement of the current word cloud? [Regenerate it](https://github.com/JessicaLim8/JessicaLim8/issues/new?title=wordcloud%7C#{SHUFFLECLOUD}&body=Just+click+%27Submit+new+issue%27%0D%0AYou+do+not+need+to+do+anything+else) :game_die:

      <div align="center">

        ## *Favourite Quarantine Passtime?* :lock: :tennis: :video_game:

        <img src="#{WORD_CLOUD_URL}" alt="WordCloud" width="100%">

        ![Word Cloud Words Badge](https://img.shields.io/badge/Words%20in%20this%20Cloud-#{current_words_added}-informational?labelColor=7D898B)
        ![Word Cloud Contributors Badge](https://img.shields.io/badge/Contributors%20this%20Cloud-#{current_contributors.size}-blueviolet?labelColor=7D898B)


    HTML

    # TODO: [![Github Badge](https://img.shields.io/badge/-@username-24292e?style=flat&logo=Github&logoColor=white&link=https://github.com/username)](https://github.com/username)

    current_contributors.each do |username, count|
      markdown.concat("[![Github Badge](https://img.shields.io/badge/-@#{format_username(username)}-24292e?style=flat&logo=Github&logoColor=white&link=https://github.com/#{username})](https://github.com/#{username}) ")
    end

    markdown.concat("</div>")
  end

  private

  def format_username(name)
      name.gsub('-', '--')
  end

  attr_reader :octokit
end
