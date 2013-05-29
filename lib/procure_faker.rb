module ProcureFaker
  class Vendor
    def self.name(index = nil)
      values = [
        "New Technology LLC",
        "Lime & Chile, LLC",
        "The Web Guys",
        "Ninth St. Consulting",
        "Chameleon Design",
        "Department of Better Technology",
        "Drakes Bay Technology",
        "Maravir",
        "HG Consulting",
        "Smith and Smith",
        "VistaField, Inc.",
        "ServerSend, Inc."
      ]

      index && values[index] ? values[index] : values.sample
    end
  end

  class Tag
    def self.name(index = nil)
      values = [
        "Web Design",
        "Web Development",
        "Content Management",
        "Procurement Software",
        "Design",
        "UX Strategy",
        "Wireframing",
        "Storyboarding",
        "Video Production",
        "Product Photography",
        "Backend Programming"
      ]

      index && values[index] ? values[index] : values.sample
    end
  end

  class Project
    def self.title(index = nil)
      values = [
        "New HHS Innovations Website",
        "Video Closed Captioning",
        "Small Business Innovative Research Commercialization Data",
        "Enhancement of SBIR/TechNet",
        "Small Business Investment Company (SBIC) Website",
        "Transactional Email System",
        "API for We The People"
      ]

      index && values[index] ? values[index] : values.sample
    end

    def self.body(index = nil)
      values = [
        "
          The Department of Health and Human Services (HHS) is the United States government's principle agency for protecting the health of all Americans and providing essential human services, especially for those who are least able to help themselves. The Chief Technology Officer for HHS leads innovation activities for the Department.   The Chief Technology Officer is responsible for creating a culture of innovation internal to HHS and leading the HHS Innovation agenda external to HHS.

          Currently, the Chief Technology Officer's innovation and open government initiatives are hosted on www.hhs.gov/open.  HHS.gov/open was established in 2008, and while an appropriate place for the HHS innovation activities at the time, HHS.gov/open no longer meets the needs of the Chief Technology Officer.    The Chief Technology Officer is seeking the development of a new website on any platform that will provide a user driven experience that will act as a platform for engagement and education of the HHS innovation initiatives. The innovations team has experience with WordPress and Drupal but is open to other platforms. The new website will provide a more information centric approach that will also provide a more user centric experience for people visiting the new HHS innovations web site.
        ",

        "
          The White House Office of Digital Strategy produces a number of video products each week including but not limited to speeches by principles including the President, press briefings by the Press Secretary and others, videos of events happening on campus, and produced pieces like West Wing Week.

          The vendor shall provide captioning service for all videos produced by the Office of Digital Strategies. Generally speeches by any of the principals shall have accompanying transcripts that can be used to generate the captions. In addition, all press briefings shall have accompanying transcripts. When applicable, as determined by the Office of Digital Strategies, the vendor shall create transcripts of videos posted to the White House YouTube channel.

          For all videos (with or without White House provided transcripts), the vendor shall create timed caption files, referred to as SRT files. The vendor will also apply the timed SRT to videos already posted to the White House YouTube channel and WhiteHouse.gov video player and Vimeo as applicable. The vendor will be provided with logins and passwords to access each of these accounts directly. Uploads to the White House YouTube account shall need to be monitored, as some videos are uploaded as \"private\" or \"unlisted\" for a day or so before they go live.
        "
      ]

      index && values[index] ? values[index] : values.sample
    end
  end

  class Question
    def self.body(index = nil)
      values = [
        "Will this be run on SQL, Oracle, or some other database system?",
        "How was it determined that all automated systems could be delivered in 60 days?",
        "Is there an incumbent? Will they also be allowed to bid on this?",
        "Please state the expected award date as a delta from the proposal submission date.",
        "Can the offeror propose a payment schedule along with the cost quote?",
        "Will the government assign a project manager full time to assist in reviews and approving design requirements?"
      ]

      index && values[index] ? values[index] : values.sample
    end
  end

  class Label
    def self.name(index = nil)
      values = [
        "Weird",
        "Awesome",
        "Needs more info",
        "Best value",
        "Too much $"
      ]

      index && values[index] ? values[index] : values.sample
    end

    def self.color(index = nil)
      values = ["898989", "E1D9D9", "E7544D", "E2EB4E", "4FEB5A", "4EDBE6", "5F55EA"]

      index && values[index] ? values[index] : values.sample
    end
  end
end