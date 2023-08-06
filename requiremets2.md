#ORG Level Service Control Policies (SCPs)
SCPs provide centralized control over the allowed actions across AWS accounts, ensuring security, compliance, and effective resource management.
Service control policies (SCPs) are a type of organization policy that you can use to manage permissions in your organization.
SCPs offer central control over the maximum available permissions for all accounts in your organization.
SCPs help you to ensure your accounts stay within your organization’s access control guidelines. SCPs are available only in an 
organization that has all features enabled. SCPs aren't available if your organization has enabled only the consolidated billing features. 
SCPs alone are not sufficient in granting permissions to the accounts in your organization. No permissions are granted by an SCP. An SCP defines a
guardrail or sets limits, on the actions that the account's administrator can delegate to the IAM users and roles in the affected accounts. 
The administrator must still attach identitybased or resourcebased policies to IAM users or roles, or to the resources in your accounts to
grant permissions.  Effective is the logical intersection between what is allowed by the SCP and what is allowed by the IAM and resource based policies.
however, an SCP never grants permissions. Instead, SCPs are JSON policies that specify the maximum permissions for the affected accounts. 
    • SCPs affect only IAM users and roles that are managed by accounts that are part of the organization. SCPs don't affect resource-based policies directly. 
      They also don't affect users or roles from accounts outside the organization. For example, consider an Amazon S3 bucket that's owned by account A in an
      organization. The bucket policy (a resource-based policy) grants access to users from account B outside the organization. Account A has an SCP attached. 
      That SCP doesn't apply to those outside users in account B. The SCP applies only to users that are managed by account A in the organization.
    • An SCP restricts permissions for IAM users and roles in member accounts, including the member account's root user. Any account has only those 
      permissions permitted by every parent above it. If permission is blocked at any level above the account, either implicitly (by not being included in an 
      Allow policy statement) or explicitly (by being included in a Deny policy statement), a user or role in the affected account can't use that permission, 
      even if the account administrator attaches the AdministratorAccess IAM policy with */* permissions to the user.
    • SCPs affect only member accounts in the organization. They have no effect on users or roles in the management account.
    • Users and roles must still be granted permissions with appropriate IAM permission policies. A user without any IAM permission 
      policies has no access, even if the applicable SCPs allow all services and all actions.

  #Network Perimeter:
  Network perimeter SCPs define the network access controls for services, considering security zones, virtual private clouds (VPCs), and IP ranges.
  Limit access from external networks to specific ports and services.
 Define SCPs to prevent public access to sensitive resources.
 Enforce secure connectivity through VPN or Direct Connect for specific services.
 #example:
  Deny Public RDP Access: Deny RDP access (port 3389) to instances in a VPC from noncorporate IP addresses.
 Allow HTTPS Only: Allow only HTTPS (port 443) access to web servers from any location.
 
```json 
 {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DenyGlobalAccess",
            "Effect": "Deny",
            "Action": "*",
            "Resource": "*",
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": "0.0.0.0/0"
                }
            }
        }
    ]
}
```

 #Data Loss Prevention:
 Data loss prevention SCPs ensure sensitive data protection by controlling actions involving data transfer, encryption, and storage.
 Prevent public access to S3 buckets containing sensitive data.
 Enforce encryption for data at rest and in transit.
 Restrict the ability to share data across accounts.

 #Example:
 Deny External S3 Bucket Sharing: Deny sharing of S3 buckets with external accounts.
 Encrypt EBS Volumes: Ensure that EBS volumes are encrypted at rest.
 
 ```json
 {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DenyS3ExternalSharing",
            "Effect": "Deny",
            "Action": "s3:PutBucketAcl",
            "Resource": "*",
            "Condition": {
                "StringEqualsIfExists": {
                    "aws:PrincipalOrgID": "o-xxxxxxxxxx"
                }
            }
        }
    ]
}

```


 #Regional Control:
 
 Regional control SCPs manage access and resources within specific AWS regions, aligning with compliance and data residency requirements.

 Restrict resource creation to specific regions.
 Allow only approved regions for specific services.
 Implement regional redundancy and failover policies.

 #Example:
 
 Allow use1 and usw2 Only: Allow resource creation only in the useast1 and uswest2 regions.

 
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyCreateResourcesUSW2",
      "Effect": "Deny",
      "Action": "ec2:RunInstances",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-west-2"
        }
      }
    }
  ]
}

 ```

 
 Deny cac1 Usage: Deny resource creation in the Canada (Central) region.

```json
 {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCreateS3BucketsEUC1",
      "Effect": "Deny",
      "Action": "s3:CreateBucket",
      "Resource": "*",
      "Condition": {
        "StringNotEqualsIfExists": {
          "s3:LocationConstraint": "eu-central-1"
        }
      }
    }
  ]
}
```


#Approved Service Management:
Approved service management SCPs ensure that only permitted services are used within each environment, 
avoiding unnecessary costs and potential security risks.
 Define service allow and deny lists per environment (e.g., Development, Production).
 Restrict access to services based on roles and responsibilities.


 #Example:
 a) Allow List for Development: Allow EC2, S3, and Lambda services for the Development environment.

 
 ```json
 {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowApprovedServicesDev",
      "Effect": "Deny",
      "Action": "ec2:*",
      "Resource": "*",
      "Condition": {
        "StringNotEqualsIfExists": {
          "aws:RequestedRegion": "us-east-1"
        }
      }
    }
  ]
}
```


b) Deny the usage of specific services in the production environment.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyUnapprovedServicesProd",
      "Effect": "Deny",
      "Action": "s3:*",
      "Resource": "*",
      "Condition": {
        "StringEqualsIfExists": {
          "aws:RequestedRegion": "us-east-1"
        }
      }
    }
  ]
}
```


#SCP Inheritance through OU Level:

SCP inheritance through Organizational Units (OUs) ensures that policies are applied hierarchically, streamlining management and maintaining consistency.
 Define SCPs at the organization level and inherit them to OUs.
 Tailor SCPs at the OU level to accommodate specific requirements.
 #Example
  OrganizationLevel Deny IAM Users: Deny IAM user creation at the organization level.
 OULevel Allow IAM Users: Allow IAM user creation within the "Development" OU.


 #EC2 Instance SCP and Maintenance procedures
 The EC2 Instance SCP defines the permissions and restrictions for managing EC2 instances at an organizational level.
 It ensures that only authorized users and roles can perform specific actions on EC2 instances, promoting the principle of least privilege.

 Least Privilege: SCPs should adhere to the principle of least privilege, allowing only the necessary actions and resources required for specific roles or groups.

Tag-Based Access: SCPs can be defined based on instance tags, enabling role-based access control for EC2 instances.

Region-Specific Restrictions: SCPs can restrict EC2 actions to specific AWS regions to enforce data residency or compliance requirements.

Instance Type Control: SCPs can limit the instance types that can be launched to control costs or enforce performance standards.

#Examples:
a) Allow Start/Stop/Reboot for Tagged Instances:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowStartStopReboot",
      "Effect": "Allow",
      "Action": [
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ec2:RebootInstances"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ec2:ResourceTag/Environment": "Production"
        }
      }
    }
  ]
}
```

b) Deny Termination of Instances with Specific Tags:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyTermination",
      "Effect": "Deny",
      "Action": "ec2:TerminateInstances",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ec2:ResourceTag/Restricted": "true"
        }
      }
    }
  ]
}
```


## EC2 Instance Maintenance Procedures

Maintaining EC2 instances is crucial to ensure their reliability, security, and performance. Proper maintenance procedures should be followed to keep instances
up to date and well-managed. Below are some best practices for EC2 instance maintenance:

Regular Patching: Apply OS patches and security updates to instances on a regular basis to protect against known vulnerabilities.

Backup and Snapshot: Regularly back up critical data and create snapshots of instances to recover from potential failures or accidental data loss.

Instance Monitoring: Implement monitoring and alerting to track instance performance and detect anomalies or potential issues.

Auto Scaling and Load Balancing: Implement auto scaling and load balancing to ensure high availability and seamless resource allocation.

#Example:
The following policy restricts all users from launching EC2 instances without IMDSv2

```json 
[
   {
      "Effect": "Deny",
      "Action":"ec2:RunInstances",
      "Resource":"arn:aws:ec2:::instance/",
      "Condition":{
         "StringNotEquals":{
            "ec2:MetadataHttpTokens":"required"
         }
      }
   },
   {
      "Effect":"Deny",
      "Action":"ec2:RunInstances",
      "Resource":"arn:aws:ec2:::instance/",
      "Condition":{
         "NumericGreaterThan":{
            "ec2:MetadataHttpPutResponseHopLimit":"3"
         }
      }
   },

   {
      "Effect":"Deny",
      "Action":"",
      "Resource":"",
      "Condition":{
         "NumericLessThan":{
            "ec2:RoleDelivery":"2.0"
         }
      }
   },
   {
      "Effect":"Deny",
      "Action":"ec2:ModifyInstanceMetadataOptions",
      "Resource":""
   }
]
```

The following policy restricts all users from disabling the default Amazon EBS Encryption
```json
{
  "Effect": "Deny",
  "Action": [
    "ec2:DisableEbsEncryptionByDefault"
  ],
  "Resource": ""
}
```


By implementing proper EC2 Instance Service Control Policies and following maintenance procedures, organizations can maintain a secure and well-managed AWS infrastructure,
ensuring high availability, reliability, and performance of EC2 instances.
Regular review and updates to SCPs and maintenance procedures will help adapt to changing business needs and security best practices.


#RAM no external share SCP
    • Preventing external sharing
    • Allowing specific accounts to share only specified resource types
    • Prevent sharing with organizations or organizational units (OUs)
    • Allow sharing with only specified IAM users and roles


1. RAM: RAM stands for "Random Access Memory." It is a type of computer memory that provides fast read and write access to data that the CPU (Central Processing Unit) uses during operation. RAM is volatile memory, meaning its contents are lost when the computer is powered off.

2. No External Share: This likely refers to a configuration where the data stored in RAM is not shared with external entities or systems. It implies that the data in RAM remains isolated and isn't accessible or shared outside of the system.

The following example SCP prevents users from creating resource shares that allow sharing with IAM users and roles that aren't part of the organization.

##example:

```json
{
    "Version": "20121017",
    "Statement": [
        {
            "Effect": "Deny",
            "Action": [
                "ram:CreateResourceShare",
                "ram:UpdateResourceShare"
            ],
            "Resource": "",
            "Condition": {
                "Bool": {
                    "ram:RequestedAllowsExternalPrincipals": "true"
                }
            }
        }
    ]
}

```



Allowing specific accounts to share only specified resource types
The following SCP allows accounts 111111111111 and 222222222222 to create resource shares that share prefix lists, and to associate prefix lists with existing resource shares.

```json
{
    "Version": "20121017",
    "Statement": [
        {
            "Sid": "OnlyNamedAccountsCanSharePrefixLists",
            "Effect": "Deny",
            "Action": [
                "ram:AssociateResourceShare",
                "ram:CreateResourceShare"
            ],
            "Resource": "",
            "Condition": {
                "StringNotEquals": {
                    "aws:PrincipalAccount": [
                        "111111111111",
                        "222222222222"
                    ]
                },
                "StringEquals": {
                    "ram:RequestedResourceType": "ec2:PrefixList"
                }
            }
        }
    ]
}
```

Prevent sharing with organizations or organizational units (OUs)
The following SCP prevents users from creating resource shares that share resources with an AWS Organization or OUs.


```json
{
    "Version": "20121017",
    "Statement": [
        {
            "Effect": "Deny",
            "Action": [
                "ram:CreateResourceShare",
                "ram:AssociateResourceShare"
            ],
            "Resource": "",
            "Condition": {
                "ForAnyValue:StringLike": {
                    "ram:Principal": [
                        "arn:aws:organizations:::organization/",
                        "arn:aws:organizations:::ou/"
                    ]
                }
            }
        }
    ]
}

```

Allow sharing with only specified IAM users and roles
The following example SCP allows users to share resources with only organization o12345abcdef, organizational unit ou98765fedcba, and account 111111111111.



```json
{
    "Version": "20121017",
    "Statement": [
        {
            "Effect": "Deny",
            "Action": [
                "ram:AssociateResourceShare",
                "ram:CreateResourceShare"
            ],
            "Resource": "",
            "Condition": {
                "ForAnyValue:StringNotEquals": {
                    "ram:Principal": [
                        "arn:aws:organizations::123456789012:organization/o12345abcdef",
                        "arn:aws:organizations::123456789012:ou/o12345abcdef/ou98765fedcba",
                        "111111111111"
                    ]
                }
            }
        }
    ]
}
```

#SCP for resource tagging


    • Require a tag on specified created resources
    • Prevent tags from being modified except by authorized principals
Require a tag on specified created resources
IAM Policies for Resource Tagging
IAM policies in AWS allow you to define permissions for users, groups, or roles to access and manage AWS resources. Resource tagging is a way to label and categorize AWS resources (such as EC2 instances, S3 buckets, etc.) with metadata called tags. Tags are key-value pairs that can be attached to resources to help organize, track, and manage them.

You can use IAM policies to control access to resources based on their tags. For example, you could create a policy that grants read-only access to EC2 instances with a specific "Environment" tag set to "Production." This would allow users or roles with that policy to view details of only those instances that match the specified tag criteria.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:DescribeInstances",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/Environment": "Production"
        }
      }
    },
    {
      "Effect": "Deny",
      "Action": "ec2:DescribeInstances",
      "Resource": "*"
    }
  ]
}
```

.

Please note that AWS services and features may have evolved since my last update, and new terminologies or concepts could have emerged. It's always a good practice to refer to the latest AWS documentation or resources for the most up-to-date information.
The following SCP prevents IAM users and roles in the affected accounts from creating certain resource types if the request doesn't include the specified tags.


```json
{
  "Version": "20121017",
  "Statement": [
    {
      "Sid": "DenyCreateSecretWithNoProjectTag",
      "Effect": "Deny",
      "Action": "secretsmanager:CreateSecret",
      "Resource": "",
      "Condition": {
        "Null": {
          "aws:RequestTag/Project": "true"
        }
      }
    },
    {
      "Sid": "DenyRunInstanceWithNoProjectTag",
      "Effect": "Deny",
      "Action": "ec2:RunInstances",
      "Resource": [
        "arn:aws:ec2:::instance/",
        "arn:aws:ec2:::volume/"
      ],
      "Condition": {
        "Null": {
          "aws:RequestTag/Project": "true"
        }
      }
    },
    {
      "Sid": "DenyCreateSecretWithNoCostCenterTag",
      "Effect": "Deny",
      "Action": "secretsmanager:CreateSecret",
      "Resource": "",
      "Condition": {
        "Null": {
          "aws:RequestTag/CostCenter": "true"
        }
      }
    },
    {
      "Sid": "DenyRunInstanceWithNoCostCenterTag",
      "Effect": "Deny",
      "Action": "ec2:RunInstances",
      "Resource": [
        "arn:aws:ec2:::instance/",
        "arn:aws:ec2:::volume/"
      ],
      "Condition": {
        "Null": {
          "aws:RequestTag/CostCenter": "true"
        }
      }
    }
  ]
}
```

Prevent tags from being modified except by authorized principals
The following SCP shows how a policy can allow only authorized principals to modify the tags attached to your resources. This is an important part of using attributebased access 8control (ABAC) as part of your AWS cloud security strategy. The policy allows a caller to modify the tags on only those resources where the authorization tag (in this example, accessproject) exactly matches the same authorization tag attached to the user or role making the request. The policy also prevents the authorized user from changing the value of the tag that is used for authorization. The calling principal must have the authorization tag to make any changes at all.
This policy only blocks unauthorized users from changing tags. An authorized user who isn't blocked by this policy must still have a separate IAM policy that explicitly grants the Allow permission on the relevant tagging APIs. As an example, if your user has an administrator policy with Allow / (allow all services and all operations), then the combination results in the administrator user being allowed to change only those tags that have an authorization tag value that matches the authorization tag value attached to the user's principal. This is because the explicit Deny in the this policy overrides the explicit Allow in the administrator policy.

```json
{
    "Version": "20121017",
    "Statement": [
        {
            "Sid": "DenyModifyTagsIfResAuthzTagAndPrinTagDontMatch",
            "Effect": "Deny",
            "Action": [
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Resource": [
                ""
            ],
            "Condition": {
                "StringNotEquals": {
                    "ec2:ResourceTag/accessproject": "${aws:PrincipalTag/accessproject}",
                    "aws:PrincipalArn": "arn:aws:iam::123456789012:role/orgadmins/iamadmin"
                },
                "Null": {
                    "ec2:ResourceTag/accessproject": false
                }
            }
        },
        {
            "Sid": "DenyModifyResAuthzTagIfPrinTagDontMatch",
            "Effect": "Deny",
            "Action": [
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Resource": [
                ""
            ],
            "Condition": {
                "StringNotEquals": {
                    "aws:RequestTag/accessproject": "${aws:PrincipalTag/accessproject}",
                    "aws:PrincipalArn": "arn:aws:iam::123456789012:role/orgadmins/iamadmin"
                },
                "ForAnyValue:StringEquals": {
                    "aws:TagKeys": [
                        "accessproject"
                    ]   
                }   
            }
        },
        {       
            "Sid": "DenyModifyTagsIfPrinTagNotExists",
            "Effect": "Deny", 
            "Action": [
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],      
            "Resource": [
                ""     
            ],      
            "Condition": {
                "StringNotEquals": {
                    "aws:PrincipalArn": "arn:aws:iam::123456789012:role/orgadmins/iamadmin"
                },      
                "Null": {
                    "aws:PrincipalTag/accessproject": true
                }       
            }       
        }
    ]
}
```



# Amazon Virtual Private CloudAmazon VPC SCP

    • Prevent users from deleting Amazon VPC flow logs
    • Prevent any VPC that doesn't already have internet access from getting it
Prevent users from deleting Amazon VPC flow logs
This SCP prevents users or roles in any affected account from deleting Amazon Elastic Compute Cloud (Amazon EC2) flow logs or CloudWatch log groups or log streams.


```json
{
  "Version": "20121017",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": [
        "ec2:DeleteFlowLogs",
        "logs:DeleteLogGroup",
        "logs:DeleteLogStream"
      ],
      "Resource": ""
    }
  ]
 }

```
Prevent any VPC that doesn't already have internet access from getting it
This SCP prevents users or roles in any affected account from changing the configuration of your Amazon EC2 virtual private clouds (VPCs) to grant them direct access to the internet. It doesn't block existing direct access or any access that routes through your onpremises network environment.


```json
{
  "Version": "20121017",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": [
        "ec2:AttachInternetGateway",
        "ec2:CreateInternetGateway",
        "ec2:CreateEgressOnlyInternetGateway",
        "ec2:CreateVpcPeeringConnection",
        "ec2:AcceptVpcPeeringConnection",
        "globalaccelerator:Create",
        "globalaccelerator:Update"
      ],
      "Resource": ""
    }
  ]
}
```
