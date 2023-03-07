# Webinar Walkthrough

## Prep

### Queue Runs

* `webinar-infra-dev`
* `webinar-infra-test`
* `webinar-infra-prod`

### Ensure Drift

* `azure-infra`


### Preload Tabs
* Terraform Cloud - `Choose Organiation`
* Azure Portal - Resource Groups - Filter for `webinar`
* AWS Console - `eu-west-2`
* Github - `hashicorp-terraform-cloud`

## Slide Exit

Thank you Chris.

Before we jump over to the actual demo content, I just want to take a minute to show you the capabilities we'll be looking at in the enterprise Terraform platform, and how they relate to the challenges that Chris has just alluded to.

Firstly, we'll take a look at Infrastructure as Code workflows. We'll have a look at how we can integrate an enterprise Terraform platform with a git-based Version Control System. If you have existing Terraform Open Souce configurations, this would be one of the first steps to being it under enterprise management. We'll also look at how we can decompose infrastructure with Workspaces, and how we can do envrionment promotion of infrastucture as code configurations in much the same way that you'd handle standard application binaries or artifacts.

Secondly, we'll have a quick look at the Private Module Registry. As Chris mentioned there are over 2,500 providers currently available for Terraform, so how can we start to break that down into presenting a more manageable, more controlled offering to users?

Thirdly, we'll look at how we can derive cost estimations from Terraform runs, in order to better forecast and control our infrastructure spend.

Finally, we'll look at using the HashiCorp Sentinel Policy as Code framework to put guardrails around what runs can and cannot affect within your infrastructure. This will show how Sentinel can be used to enforce infrastructure standards, and enforce spending limits using cost estimation data.

## Demo

* Be logged in to avoid MFA nonsense

Once logged in to the Terraform Platform, we need to chose an organisation to work in. An organisation is a shared space where one or many Teams can collaborate.

* Choose an Organisation - `ben-holmes`

Now, an organisation holds some global configuration settings. 

Key ones for today will be `Variable Sets` and `Policy Sets`, but we'll look at those in a second. As you can see you can also use this settings page to manage your Users, your Teams, and a whole host of other security, integration, and VCS related settings.

We can also see that an organisation contains Projects and Workspaces.

Projects let you organise your workspaces and scope access to workspace resources, whilst the workspace itself represents a collection of infrastructure components; configuration state, data, and variables.

### Version Control System Integration

So let's have a look at bringing a project into the enterprise Terrafrom platform.

Now, we can create a workspace in the UI. Workspaces can have a Version control workflow, a CLI workflow, or an API workflow.

The most common of these is the Version Control workflow, and that's what we'll do here.

* Create New Workspace called `aws-infra` from `aws-infra` repository in Github.

Terraform Cloud is going to parse the configuration it finds in source control, and let me know what variables I need to provide out of the box. It shows us that we need to provide an Instance Name, and an SSH Key in order to access the instance. I'm going to leave the SSH key for now, but let's give our instance a name:

```
instance_name  =  webinar-feb-23
```

* Save Variables
* Workspace Overview

Now we need to sort out that SSH Key. To do this, I'm going to use a Variable Set. You can think of Variable Sets as logical groupings of Variables that you may wish to manage outside the lifecycle of a Workspace. For example, common tags on resources, credentials or keys that should be applied to multiple workspaces.

* Assign Variable Sets - AWS Credentials, SSH Public Key

* Plan & Apply

You can see from the structured output that Teraform is provisioning the resources in AWS. You can clearly see that it's creating the instance, the SSH key, and a security group for the instance.

Whilst we wait for that to finish, let's have a quick look at some of the elements in the Workspace View here.

`Overview` gives me an 'at a glance' representation of the state of workspace. This is a project driven directly from Source Control. From the overview there's a link directly back to the git repository it's come from - it's important to remember that we have a 1-to-1 mappting between Terraform Workspace here, and a Git branch.

* Follow Git link

`Runs` allow me to see a list of current, pending, and historical runs. So I have a history of the operations that Terraform has driven here.

`States` just gives me a view on the current state file, such as it is.

`Variables` allos me to manage what Variables are available to the workspace - whether created on a per workspace basis, or applied from a Variable Set.

I'll just pop open the AWS console and we can see how that EC2 instance is coming along.

* Open up AWS Managament Console in eu-west-2

### Decomposing Infrastructure

One of the goals of an enterprise Terraform Platform is to allow different infrastructure teams to work collaboratively at scale, whilst ensuring that their work and the resources under management are protected by a robust security model. One of the ways it can do this is by allowing teams to decompose infrastructure components into different Projects and Workspaces which we touched on briefly at the start of the demo.

In true Blue Peter fashion, here is a Project, `HE Webinar` that I created earlier.

* HE Webinar Project

In it are a number of different workspaces, representing different infrastructure components for different environments - I have my `Webinar-Infra` workspaces, which define some basic Azure resources - resource groups and network configurations. Additionally, I have my `Webinar-Compute` workspaces whcih define some compute resource to deploy into my `Infra` workspaces. In this way, I could have my Infrastructure team working on and maintaining the Infrastructurre resources, and I could have perhaps an Application or Product team looking after the compute resources - they have no need to know how the infrastructure is provisioned, just that it's there in the first place.

* Webinar-Infra-Dev Workspace

If we have a look in the Settings for a Workspace, you'll see a `Team Access` option.

* Team Access
* Add Teams and Permissions
* Select Admin Team

Using this, we can drill into the finer details of how we can assign some of the default roles that exist within the platform, and how we can enable more fine grained customisation of those.

And this is something you can also do at the Project level, although at the time of this talk Projects have only been Generally Available for a few weeks and will continue to evolve as time goes on. But hopefully you can see how you might start to create a comprehensive permissions model around who can access the Projects and Workspaces managed by Terraform here.

## Environment Promotion

Right, that's enough hand waving. Let's do something proper.

* HE Webinar Project
* webinar-infra-dev

If we have a look at the `webinar-infra-dev` workspace, the structured output clearly shows that there's something wrong here. Not wrong enough to stop the apply, but something that requires our attention.

* Open `Policy Check`

We can see that a Policy has failed its check here. We'll touch on the specifics of Policies in a minute, but broadly speaking policies are rules that Terraform enforces on runs.

In this case, I've defined a Policy called `enforce-resource-group-tags`, which as the name suggests, checks for the presence of specific tags on Azure Resource Groups but this has clearly failed. The output tells us that its because we don't have `owner` and `contact` tags on the Resource Group. 

Perhaps there's some organisational governance in place that says these are required so that we don't end up with unaccountable cloud usage, and ultimately wastage. Or, alternatively, an unmarked Resource Group that ostensibly doesn't belong to anyone, but is happily running a Production Service - you know, the cloud-native equivalent of the unmarked box under someone's desk that happens to be running critical production infrastructure. I'm sure we've all been there.

I'm just going to verify what the Policy is telling me in Azure.

* Open Azure Portal
* Find `webinar-infra-dev` resource Group
* Show Tags

Oh look. We don't have `owner` or `contact` tags. Let's do something about that, and show off the Terraform Platform's more advanced source control integrations in the process.

* Terraform Cloud
* HE Webinar
* Filter on `infra`

Remember when I said that in the Terraform platform there was a 1-to-1 mapping between a Workspace and a Git Branch? Well, that's exactly what we've got going on here - I have a single Git repository with 3 branches - `dev`, `test`, and `prod`, and these map to my `infra-dev`,`infra-test`, and `infra-prod` Workspaces. And this allows us to do some pretty cool stuff.

* GitHub
* `hashicorp-terraform-cloud/he-webinar-infra/extra-tags.auto.tfvars`
* BE ON THE DEV BRANCH

Now, I could add tags as variables, or as defaults in my configuration but because I want to show you this specific Git integration I'm just going to edit this `tfvars` file on my `dev` branch.

```
extra_tags = {
owner = "Ben Holmes"
contact = "app-team@onmi.cloud"
}
```

* Commit

```
Added mandatory tags to Resource Group
```

Let's commit that. If we quickly jump back to the Terraform Platform you'll see that this has automatically triggered a Run. When the Policy Checks complete, we should hopefully see that the they are now passing. That's great, we can Apply that, and get our mandatory labels in place in `dev`.

* GitHub

But let's raise a Pull Request, and see what happens.

* Pull Requests
* Compare and Pull Request
* Base: Test <- Dev

```
PR to add mandatory tags to Resource Group
```

We can see that there are a number of Checks being carried out. This essentially boils down to what's called Speculative Plan being executed in the affected workspacs - in this case, `dev` and `test` - to show us what the effect of merging this Pull Request into the Test Branch would be. 

* Click through from `test` check to Terraform Cloud

I cannot stress enough that as this is only a Speculative Plan, it can never be applied to that `test` workspaces in the Terraform platform - even by a platform administrator. It serves to show you the delta between the Pull Request, and the current state of your infrastructure.

Applying these changes can only be done when we actually Merge this Pull Request into the `test` branch. 

Let me just do that. So then we can see, just like in `dev` the Policy Check completes succesfully.

* Confirm and Apply
* Azure Portal
* Look at `webinar-infra*` Resource Groups for Tags

That concludes our look at source control integration features in the Terraform platform. I think it's really important to highlight the different ways we can leverage the platform's integration with source control - so often when we go and talk to customers the conversation starts "we've built out this scaffolding and glue code around Terraform OSS. It works, but maintaining it is time consuming and expensive'. Here we've seen how we can get up and running quickly and easily, with no scaffolding required.

### 2500 Providers

Moving on...

One of the things talked about during the presentation is that Terraform supports over 2,500 providers. That's a lot of supported infrastructure backends to deal with, and it can be overwhelming to know where to start, and what providers are recommended for use within your environment. And that's before you get into the realms of Terraform Modules that act as a wrapper around reusable Terraform configurations and how those can be consumed

This is where the Terraform Platform's Private Module Registry comes in handy.

* Organisation
* Private Module Registry
* Providers

One of the basic features is just to act as a source of truth for those recommended providers - making supporting documentation and examples available from a central location. As you can see, I've decided that my organisation is going to encourage the use of a couple of Azure Providers, the AWS Provider, and the Kubernetes Provider. The other Provider, whilst not necessarily on the critical path for infrastructure managamenet, is no less important - it shows how I can order a Pizza using Terraform.

* Modules

With regards to Modules, as much as I'd like it to be the case not everyone needs or wants to be is a Terraform rockstar. The use of the Private Module Registry allows us to create a producer-consumer model around Modules specific to an organisation. This gives us the ability to create either low code, or no code workflows within the Terraform platform.

Let's just have a quick look at one of the modules I've published here, which is a module I've created to create a number of Red Hat Enterprise Linux instances in Azure: 

* rhel-standard

As as you can see from this overview we can see some of the details of the module such as this absolutely stellar Readme Document, the version history, and the Git repository the module is sourced from. 

* Inputs

We can see the inputs required when consuming the module

* Outputs

and the Outputs we expect to see after it has run

* Resources

and crucially the types of resources it'll create. 

On the righthand side we can see exactly how we can use the Module, and some metrics about the current module utilisation.

As I step forward through the demo, I'll be using this module here to define and create my compute resources.

So let's do that.

### Integrated Cost Estimation

None of the resources we've deployed so far have had a significant cost associated with them.

* `webinar-infra-compute`

Let's change that.

* Actions -> Start New Run

Thinking back to our composable infrastructure, what this is going to do is create a compute resource, with a cost associated with it, in the Resource Group managed by the `webinar-infra-dev` Workspace. All we're doing here is consuming that Resource Group that has already been created.

* Look at `Estimated Cost Increase`
* Open `Cost Estimation Finished` tab
* Confirm and Apply

It's worth noting that the pricing shown in our SaaS offering - the one I'm working with here - will only show estimations based on the publically published list prices for resources in the cloud environment at the moment the infrastructure changes get applied. If the price tomorrow is less than it is today, then tomorow's runs will show tomorrow's pricing. If you have a commercial deal with one of the supported infrastructure providers - say, a 40% discount on cloud spend across the board - that would not be reflected in this particular picing metric. However, it is possible to write policies that take the particulars of your commercial terms into account. If you know you have a 40% discount across the board, then you can write a policy that takes the list price, calculates 40% of that, and measures the run cost deltas based on the resulting price.

In any case, they're a good indication of value of your relative spends on particular infrastructure changes.

### Risk Reduction through Policy As Code

Now we've deployed some Compute resources, let's talk about Policies.

* Organisation
* Settings
* Policy Sets

The Terraform platform enforces governance through the use of a Policy as Code framework. Using a Policy as Code framework allows us to codify our organisational governance, and lifecycle that in much the same way we do with our infrastructure. This means that your security stakeholders could take ownership of the policies in effect across the infrastructure estate, managing and maintaining them on a seperate cadence to the infrastucture resources.

One of the nice things about Sentinel Policies is that they are assessed before any changes to your infrastructure are actually made. This means that you won't get a Policy failure halfway through your Terraform run, leaving your infrastructure in an inconsistent and potentialy difficult to reconcile state.

Sentinel Policies are the primary framework for Policy creation, and that's what I've used here - but we also support the Open Policy Agent framework.

When we configure Policies in the Terraform platform, we can define them inline within the platform, or import them from Source Control as Policy Sets, which is the recommended way of working with them.

* `azure-sentinel-policies`

Policy Sets are just a grouping of policies that you create, and apply to one or more workspaces within your organisation. If drill down into this Policy Set, we can easily see where it's sourced from, the workspaces it's applied to, and any parameters influencing its behaviour.

* Workspaces
* HE Webinar
* Filter `compute`
* `webinar-compute-dev`

Earlier in the session we took a quick look at the effect that a Sentinel Policy had on our infrastructure run - we saw that it was giving us an advisory warning because my Resource Group was missing some mandatory tags. Obviously enforcing Resource Tags is one thing, another might be limiting the days of the week that infrastructure changes are permitted, or limiting the types of Virtual Instance a Terraform Configuration can create - I might say that my users can only ever create specific B Series and D series instance types in Azure - and so we don't accidentally get some GPU-optimised monster that costs us 2 grand a month, running an nginx web server. I'm sure we've all been there.

Sentinel policies can be enforced at three levels - Advisory, Soft Mandatory, and Hard Mandatory. 

When a Policy is Advisory - Like my earlier tags Policy - it is allowed to fail. However, a warning should be shown to the user or logged. This is the default enforcement level.

Soft Mandatory means that the Policy must pass unless it is explicitly overidden. The purpose of Soft Mandatory level is to provide a level of privilege separation for the behavior being governed by the Policy. Additionally, that override provides non-repudiation since at least the user was explicitly overriding a failed policy.

Hard Mandatory means that the policy must pass, without exception or override. The only way to override a hard mandatory policy is to explicitly remove the policy. It should be used in situations where the ability to override is neither warranted nor desirable.

If I look at Policy Check Passed section of the Structured Output, I can see that in addition to my Resource Group tags policy, I have a Policy called `enforce-cost-limits`. Because I wrote this policy, I know that it enforces a limit on cost deltas per run of $100. My previous run passed because it was `$ESTIMATED COST`.

Let's add another compute instance in here and see what happens.

* Variables

Because this is Terraform, and I'm fundamentally lazy, I'm not going to crank out more Terraform code. I built my module to support the creation of `n` instances based on the `vm_instance_count` variable. So I'm just going to bump that up to 3 and start a new run.

* Edit `vm_instance_count` - 3
* Save Variable
* Actions
* Start New Run

This new run will take the new value of `vm_instance_count` into account, and try and reconcile my infratructure state accordingly, by creating two new instance in the `infra-dev` resource group.

Or will it?

It looks like the Policy Check Soft Failed, because the cost delta for this run would breach my POlicy-enforced cost limit. Looking at the Cost Estimate, I can see that my cost delta would be `$COST DELTA`. This is quite far in excess of what my Policy permits, but because it's enforcing at the Soft Mandatory level, it's asking me if I want to override this and apply my changes anyway. This might be desirable if say, you're dealing with a situation where the cost limit has only been broken by a pound or two, and you urgently need the new resources to cope with an unexpected increase in traffic. Something like that.

Let me override that, and we'll roll these resources out into our Azure resource group.

## BAIL OUT POINT

### Health Checks

The last thing I wanted to touch on briefly was the concept of Health Checking. In each workspace, you may have seen this `Health` option on the sidebar here.

* Azure Infra
* `azure-infra`
* Health

This gives us access to couple of nice feature in the platform - namely Drift Detection, and Continuous Validation.

* Drift Detection

Drift Detection is all about regularly ensuring that the Current State and the Desired State of your infrastructure are in sync, Essentially, this function is all about alerting you to any changes made outside of the control of the Terraform platform - for example, if an errant sysadmin decides to change the instance type of a VM directly with the cloud provider-specific tooling

If I pop open this Resource Group resource, I can see that my configuration has drifted wildly, and one of my tags now has a different value to the one that the Terraform platform was expecting. Now I know the drift is there, I can either accept the change into my state so that isn't alerted on again (knowing that unless I change my Terraform configuration to compensate, the next time I run an apply, the value will be reset to what's in my code) or I can react by immediately running a Plan and Apply to correct the errant resource.

* Continuous Validation is a neat little feature that's currently in Beta. As some of you may be aware, the Terraform language allows for the creation of `preconiditon` and `postcondition` blocks, which can help you validate your configuration. The Continuous Validation feature lets the Terraform platform regularly check whether the preconditions and postconditions in a workspace’s configuration continue to pass, validating the real-world infrastructure for you. For example, you could have a postcondition to check whether a certificate is valid. Continuous validation would alert you when the condition fails, so you can update the certificate and avoid errors the next time you want to update your infrastructure.

That's all I wanted to talk about and show for today. I'll now hand back over to Chris to wrap up.

### Handover
















Policy Sets are just a grouping of policies that you create, and apply to one or more workspaces within your organisation. Depending on the enforcement level set on the policy - either advisory or mandatory - a failed policy can prevent the Terraform run from occuring.