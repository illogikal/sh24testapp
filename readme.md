**SH 24 Test app implementation**

GET url: **/**

Login with github username and either password or token
details saved in session.

Once logged in, can search and log out.

POST url: **/login**

Params: login, password

Logs in with GH creds to search

POST url: **/logout**

Params: login, password

Logs in with GH creds to search

GET url: **/search** (ajax)

Params: name

Search for users by GH username.

Top 2 best guesses returned (if applicable)

GET url: **/template** (ajax)

Template created to image spec and overlaid.
