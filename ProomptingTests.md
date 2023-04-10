I need an ARM template for azure with the following azure resources

azure frontdoor connected to a web application gateway


the web application gateway will connect to 2 pools, one called /images and another that will handle all other requests

the /images pool should have 2 virtual machines both running windows and will each have a powershell startup script to install IIS and have the default homepage changed to say "hello world" in red text

the other pool will contain 3 virtual machines that will run linux and nginx web server, they will have the default page replaced with "hello open source world"

the arm template will have parameters for the operating systems, the SKU of the virtual machines, the resource group it is to be deployed into and the azure region it is to be deployed into do not stop until the whole ARM template is generated - CODE ONLY

Result = Fail to generate the whole ARM template

----------------------------

I need an azure ARM template that contains a public load balancer and a backend pool of 3 virtual machines. The Virtual machines will run Linux and Nginx. They will pull a git repo from https://github.com/kramit/CoffeeShopTemplate.git and host the website stored in it

Result = Generated the whole tempalate after some extra encouragement
Working? = Nope, complete mess
File = gptarmtest2.json

Then fed it back into GPT with " Fix this ARM template *ctrl+v this borked template*

Result = it gave up 1/2 way through generating the template

---------------------------

Lets try powershell ?

I need an azure powerhsell script that will build a public load balancer and a backend pool of 3 virtual machines. The Virtual machines will run Linux and Nginx. They will pull a git repo from https://github.com/kramit/CoffeeShopTemplate.git and host the website stored in it

Result = Created the script with a little extra encouragement
Deploymet ? = nope, fails because it inserted commands that do not exist.
File = gptpstest1.ps1


---------------------

I need an azure CLI script that will build a public load balancer and a backend pool of 3 virtual machines. The Virtual machines will run Linux and Nginx. They will pull a git repo from https://github.com/kramit/CoffeeShopTemplate.git and host the website stored in it

File = gptclitest1.sh
Restult = Created the script with a little extra encouragement
deployment? = fail, halucinated command inputs


--------------------

create a basic azure load balancer called "mikeLB" as a powershell script


File = gptpstest2.sh
Restult = Created the script in one go
deployment? = PASS! Actually worked when I gave it a loction to deploy to 


-----------------

