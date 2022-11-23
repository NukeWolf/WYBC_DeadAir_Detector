## Using Respository

- Modify `env_template` file and rename to `env`
- Setup `check_dead_air.sh` script to run on a cron job.
- Modify global variables and environment in `env` and `check_dead_air.sh`.
- Code will send an API get request to Google Scripts Webapp. From here, you can send an email or do whatever as a trigger.

## Resources Used

- http://projects.sappharad.com/mp3gain/

## Example Google Scripts App

```
function doGet(req) {
  GmailApp.sendEmail(<email>,"[ALERT] Dead Air Detected",`Detected at ${new Date().toLocaleString()}`);
}
```
