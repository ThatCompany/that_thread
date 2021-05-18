# That Thread Plugin

This plugin makes it possible to have threaded conversations in issues and forums. It does this by:

- Allowing to reply to particular issue notes and forum message.
- Providing buttons, that can be used to navigate the thread tree.
*This has to be enabled in the plugin's settings.*

![Navigation buttons](navigation.png)

- Including the whole conversation into email notifications.
*This has to be enabled in the plugin's settings.*
- For Redmine 4.0 and below: Making it possible for email clients to build threads from Redmine email notifications.
*This is included into Redmine 4.1 and above. For Redmine 4.0 and below this has to be enabled in the plugin's settings.*

## Installation

- Move `that_thread` directory to the `plugins` directory of Redmine
- Run `rake redmine:plugins:migrate RAILS_ENV=production`
- Restart Redmine

## License

GNU General Public License (GPL) v2.0

## Used Icons

- https://www.iconfinder.com/icons/1814087/arrow_top_up_icon (Alexander Madyankin, Roman Shamin)
- https://www.iconfinder.com/icons/1814084/arrow_back_left_previous_icon (Alexander Madyankin, Roman Shamin)
- https://www.iconfinder.com/icons/1814082/arrow_bottom_down_icon (Alexander Madyankin, Roman Shamin)
- https://www.iconfinder.com/icons/1814086/arrow_forward_next_right_icon (Alexander Madyankin, Roman Shamin)
