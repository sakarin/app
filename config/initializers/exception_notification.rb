App::Application.config.middleware.use ExceptionNotifier,
                                       :email_prefix => "[ERROR] ",
                                       :sender_address => '"Notifier" <notifier@thefootballshirt.com>',
                                       :exception_recipients => ['sakarin.my@gmail.com']