Using the tempalate with infrared requires additional changes
as ansible copy applies another templating. Add {% raw %} with
j2.j2 as nic config file extension to overcome it. File extension
is not mandatory, but align it with infrared tempaltes so that it
it is easy for deployment.
