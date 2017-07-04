push_text = ""
navigate_text = ""

web_root = '/usr/share/nginx/html'
directories = Dir.entries(web_root).select { |file| File.directory? File.join(web_root, file) and !(file =='.' || file == '..')}

directories.each do |folder|
  if File.file?(web_root+'/'+folder+'/portal_data.txt')
    puts "found portal_data in #{File.basename(Dir.getwd)}"
    File.open( web_root+'/'+folder+'portal_data.txt' ).each do |line|

          @title = line.match(/^title:\s*\"(.*)\"$/)[1] if line[/title/]
          @id = line.match(/^id:\s*\"(.*)\"$$/)[1] if line[/id/]
          @image = line.match(/^image:\s*\"(.*)\"$/)[1] if line[/image/]
          @description = line.match(/^description:\s*\"(.*)\"$/)[1] if line[/description/]
          @dirname = File.basename(Dir.getwd)

    end

    push_text += "this.apps.push({\n  title: \"#{@title}\",\n  id: \"#{@title}\",\n  launch: \"#{@title}\",\n  image: \"#{web_root}/#{@dirname}/#{@image}\",\n  description: \"#{@description}\"\n});\n"
    navigate_text +=  "else if (id == \"#{@id}\") {\n  logger.info(\"navigating to #{@id}\");\n  window.open(window.location.origin + \"/#{@dirname}/\");\n}\n"

  end
end

home_js = "(function (app) {
    var img_dir = \"assets/img/\";
    app.HomeView = app.View.extend({
        initialize: function () {
            //only create template once, but ensure that creation takes place after app is loaded
            if (!this.template) app.HomeView.prototype.template = this.template || _.template($('#home-template').html());

            this.apps = [];
            this.apps.push({
                title: \"SMILE\",
                id: \"smile\",
                launch: \"Make a Question\",
                image: img_dir + \"smile_grey.png\",
                description: \"SMILE flips a traditional classroom into a highly interactive learning environment by engaging learners in critical reasoning and problem solving while enabling them to generate, share, and evaluate multimedia-rich inquiries.\"
            });
            this.apps.push({
                title: \"Wikipedia\",
                id: \"wikipedia\",
                launch: \"Find Information\",
                image: img_dir + \"wikipedia.png\",
                description: \"Wikipedia is the world's largest collaborative encyclopedia. This selection of articles for schools is searchable and contains 6000 articles, 26 million words and 50,000 images!\"
            });
            this.apps.push({
                title: \"Khan Academy\",
                id: \"khan\",
                launch: \"Learn Math\",
                image: img_dir + \"khan_academy.png\",
                description: \"KA Lite allows for blended learning opportunities using the core Khan Academy maths exercises.\"
            });"

home_js += push_text

home_js += "this.userName = app.localStorage.getItem(\"who\");
},

events: {
'click .close': 'closeButton',
'click .resource-btn': 'buttonPress',
'keyup input.smile-username': 'changeName',
},

closeButton: function(ev) {
var target = ev.target;
var parent = target.parentElement.parentElement;
logger.info(\"closed: \" + parent.className);
$(parent).remove();
showWelcomeMsg = false;
},

buttonPress: function(ev) {
console.log(ev);

// get app ID and title
var id = ev.currentTarget.getAttribute(\"data-app-id\");
var title = ev.currentTarget.getAttribute(\"data-app-title\");

// check to see if username exists
if (!this.userName || this.userName.length === 0) {
    window.alert('Please enter your name first!');
    jQuery('input#username').focus();
    jQuery('input#username').css('border', '1px solid #8c1515');
    return false;
}

// show the loading modal
app.showLoadingModal({ \"text\": \"Loading \" + title });

// post usage to couchdb
jQuery.post( \"/smileService/usage\", { who: app.localStorage.getItem(\"who\"), who_uuid: app.localStorage.getItem(\"who_uuid\"), what: \"opened\", message: \"the \" + id + \" app\" } );

// launch application
if (id == \"smile\") {
    logger.info(\"navigating to app smile\");
    window.open(window.location.origin + \"/smileService/auth/lti?user=\" + this.userName + \"&UUID=\" + app.localStorage.getItem(\"who_uuid\"));
} else if (id == \"wikipedia\") {
    logger.info(\"navigating to wikipeda\");
    window.open(window.location.origin + \":8001/wikipedia_en_for_schools_opt_2013/\");
} else if (id == \"khan\") {
    logger.info(\"navigating to khan\");
    window.open(window.location.origin + \":8008/\");
}\n"

home_js += navigate_text

home_js += "app.showLoginModal();
        },

        changeName: function (event) {
            var newName = event.target.value;

            app.localStorage.setItem(\"who\", newName);
            this.userName = newName;
        },

        render: function (options) {
            //apps are defined in init
            this.$el.html(this.template({ placeholder: this.randomName, username: this.userName, apps: this.apps } ));
            var that = this;

            logger.info(\"HomeView rendered\");
            return this;
        },

        remove: function () {
            logger.info(\"HomeView removed\");
            this.parentRemove();
        }
    })
})(app);\n"

File.open("home.js", "w") do |f|
  f.puts home_js
end
