import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:readybill/components/color_constants.dart';
import 'package:readybill/components/custom_components.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  Widget headingText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: black,
        fontFamily: 'Roboto_Regular',
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget subText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: black,
        fontFamily: 'Roboto_Regular',
        fontSize: 14,
        // fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget divider() {
    return const Divider(
      thickness: 1,
      color: green2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("Terms & Conditions"),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              headingText("Acceptance of Terms"),
              divider(),
              subText(
                  'The service that Ready Bill provides to user is subject to the following terms of use ("tou"). Ready Bill reserves the rights to update the tou at any time without notice to user. The most current version of the tou can be reviewed by clicking on the “terms of use” hypertext link located at the bottom of our web pages.\n\n This agreement, which incorporates by reference other provisions applicable to use of https://www.readybill.app (“website”) and the Ready Bill Mobile App, including, but not limited to, supplemental terms and conditions set forth hereof ("supplemental terms") governing the use of certain specific material contained in website, sets forth the terms and conditions that apply to use of website by user. By using website (other than to read this agreement for the first time), user agrees to comply with all of the terms and conditions hereof. The right to use website is personal to user and is not transferable to any person or entity. User is responsible for all use of user\'s account (under any screen name or password) and for ensuring that all use of user\'s account complies fully with the provisions of this agreement. User shall be responsible for protecting the confidentiality of user\'s password(s), if any.\n\nReady Bill shall have the right at any time to change or discontinue any aspect or feature of website and mobile app, including, but not limited to, content, hours of availability, and equipment needed for access or use.'),
              divider(),
              headingText("Changed terms"),
              divider(),
              subText(
                  "Ready Bill shall have the right at any time to change or modify the terms and conditions applicable to user\'s use of website and mobile app, or any part thereof, or to impose new conditions, including, but not limited to, adding fees and charges for use. Such changes, modifications, additions or deletions shall be effective immediately upon notice thereof, which may be given by means including, but not limited to, posting on website, or by electronic or conventional mail, or by any other means by which user obtains notice thereof. Any use of website by user after such notice shall be deemed to constitute acceptance by user of such changes, modifications or additions."),
              divider(),
              headingText("Description of services"),
              divider(),
              subText(
                  'Through its web property, Ready Bill provides user with access to a variety of resources, including download areas, communication forums and product information (collectively "services"). The services, including any updates, enhancements, new features, and/or the addition of any new web properties, are subject to the tou.'),
              divider(),
              headingText('Equipment'),
              divider(),
              subText(
                  'User shall be responsible for obtaining and maintaining all telephone, computer hardware, software and other equipment needed for access to and use of website and mobile app and all charges related thereof.'),
              divider(),
              headingText('User conduct'),
              divider(),
              subText(
                  'User shall use website or mobile app for lawful purposes only. User shall not post or transmit through website or mobile app any material which violates or infringes in any way upon the rights of others, which is unlawful, threatening, abusive, defamatory, invasive of privacy or publicity rights, vulgar, obscene, profane or otherwise objectionable, which encourages conduct that would constitute a criminal offense, give rise to civil liability or otherwise violate any law, or which, without Ready Bill\'s express prior approval, contains advertising or any solicitation with respect to products or services. Any conduct by user that in Ready Bill\'s discretion restricts or inhibits any other user from using or enjoying website will not be permitted. User shall not use website or mobile app to advertise or perform any commercial solicitation, including, but not limited to, the solicitation of users to become subscribers of other on-line information services competitive with Ready Bill.\n\nWebsite and mobile app contains copyrighted material, trademarks and other proprietary information, including, but not limited to, text, software, photos, video, graphics, music and sound, and the entire contents of website are copyrighted as a collective work under the indian copyright laws. Ready Bill owns a copyright in the selection, coordination, arrangement and enhancement of such content, as well as in the content original to it.\n\nUser may not modify, publish, transmit, participate in the transfer or sale, create derivative works, or in any way exploit, any of the content, in whole or in part. User may download copyrighted material for user\'s personal use only. Except as otherwise expressly permitted under copyright law, no copying, redistribution, re-transmission, publication or commercial exploitation of downloaded material will be permitted without the express permission of Ready Bill and the copyright owner. In the event of any permitted copying, redistribution or publication of copyrighted material, no changes in or deletion of author attribution, trademark legend or copyright notice shall be made. User acknowledges that it does not acquire any ownership rights by downloading copyrighted material.\n\nUser shall not upload, post or otherwise make available on website or mobile app any material protected by copyright, trademark or other proprietary right without the express permission of the owner of the copyright, trademark or other proprietary right and the burden of determining that any material is not protected by copyright rests with user. User shall be solely liable for any damage resulting from any infringement of copyright, proprietary rights, or any other harm resulting from such a submission.\n\nBy submitting material to any public area of website or mobile app, user automatically grants or warrants that the owner of such material has expressly granted Ready Bill the royalty-free, perpetual, irrevocable, non-exclusive right and license to use, reproduce, modify, adapt, publish, translate and distribute such material (in whole or in part) worldwide and/or to incorporate it in other works in any form, media or technology now known or hereafter developed for the full term of any copyright that may exist in such material. User also permits any other user to access, view, store or reproduce the material for that user\'s personal use. User hereby grants Ready Bill the right to edit, copy, publish and distribute any material made available on website by user. The foregoing provision of section 5 are for the benefit of Ready Bill, its subsidiaries, affiliates and its third party content providers and licensors and each shall have the right to assert and enforce such provisions directly or on its own behalf.'),
              divider(),
              headingText('Use of services'),
              divider(),
              subText(
                  'The services may contain email services, bulletin board services, chat areas, news groups, forums, communities, personal web pages, calendars, photo albums and/or other message or communication facilities designed to enable user to communicate with others (each a "communication service" and collectively "communication services"). User agrees to use the communication services only to post, send and receive messages and materials that are proper and, when applicable, related to the particular communication service. By way of example, and not as a limitation, user agrees that when using the communication services, user will not:\n\nUse the communication services in connection with surveys, contests, pyramid schemes, chain letters, junk emails, spamming or any duplicative or unsolicited messages (commercial or otherwise).\n\nDefame, abuse, harass, stalk, threaten, or otherwise violate the legal rights (such as rights of privacy and publicity) of others.\n\nPublish, post, upload, distribute or disseminate any inappropriate, profane, defamatory, obscene, indecent or unlawful topic, name, material or information. Upload, or otherwise make available, files that contain images, photographs, software or other material protected by intellectual property laws, including, by way of example, and not as limitation, copyright or trademark laws (or by rights of privacy or publicity) unless user own or control the rights thereto or have received all necessary consent to do the same.\n\nUse any material or information, including images or photographs, which are made available through the services in any manner that infringes any copyright, trademark, patent, trade secret, or other proprietary right of any party.\n\nUpload files that contain viruses, trojan horses, worms, time bombs, cancel bolts, corrupted files, or any other similar software or programs that may damage the operation of another\'s computer or property of another.\n\nAdvertise or offer to sell or buy any goods or services for any business purpose, unless such communication services specifically allows such messages Download any file posted by another user of a communication service that user know, or reasonably should know, cannot be legally reproduced, displayed, performed, and/or distributed in such manner.\n\nFalsify or delete any copyright management information, such as author attribution, legal or other proper notices or proprietary designations or labels of the origin or source of software or other materials contained in a file that is uploaded.\n\nRestrict or inhibit any other user from using and enjoying the communication services.\n\nViolate any code of conduct or other guidelines which may be applicable for any particular communication services.\n\nHarvest or otherwise collect information about others, including email addresses.\n\nViolate any applicable laws or regulations.\n\nCreate a false identity for the purpose of misleading others.\n\nUse, download or otherwise copy, or provide (whether or not for a free) to a person or entity any directory of users of the services or other user or usage information or any portion thereof.\n\nReady Bill has no obligation to monitor the communication services. However, Ready Bill reserves the right to review materials posted to the communication services and to remove any material in its sole discretion. Ready Bill reserves the right to terminate user\'s access to any or all of the communication services at any time, without notice, for any reason whatsoever. Ready Bill reserves the right at all times to disclose any information as it deems necessary to satisfy any applicable law, regulations, legal process or governmental request, or to edit, refuse to post or to remove any information or material, in whole or in part, in Ready Bill\'s sole discretion.\n\nMaterials uploaded to the communication services may be subject to posted limitations on usage, reproduction and/or dissemination; user is responsible for adhering to such limitations if user downloads the materials.\n\nAlways use caution when giving out any personally identifiable information in any communication services. Ready Bill does not control or endorse the content, message or information found in any communication services and, therefore, Ready Bill specifically disclaims any liability with regard to the communication services and any actions resulting from user\'s participation in any communication services. Managers and hosts are not authorized Ready Bill spokespersons, and their views do not necessarily reflect those of Ready Bill.'),
              divider(),
              headingText('Member account, password and security'),
              divider(),
              subText(
                  'If any of the services require user to open an account, user must complete the registration process by providing Ready Bill with current, complete and accurate information as prompted by the applicable registration form. User also will choose a password. User is entirely responsible for maintaining the confidentiality of user\'s password and account. Furthermost, user is entirely responsible for any and all activities that occur under user\'s account. User agrees to notify Ready Bill immediately of any unauthorized use of user\'s account or any other breach of security. Ready Bill will not be liable for any loss that user may incur as a result of someone else using user\'s password or account, either with or without user\'s knowledge. However, user could be held liable for losses incurred by Ready Bill or another party due to someone else using user\'s account or password. User may not use anyone else\'s account at any time, without the permission of the account holder.'),
              divider(),
              headingText('Notice specific to apps available on this website'),
              divider(),
              subText(
                  'Any mobile app that is made available to download from the Google Play Store or the Apple Store is the copyrighted work of Ready Bill. Use of the mobile app is governed by the terms of the end user license agreement, if any, which companies or is included in the mobile app ("license agreement"). An end user will be unable to install any app that is accompanied by or includes a license agreement, unless he or she first agrees to license agreement terms. The software is made available for download solely for use by end users according to the license agreement.'),
              divider(),
              headingText(
                  'Notice specific to documents available on this site'),
              divider(),
              subText(
                  'Permission to use documents (such as white papers, press release, datasheets and faqs) from the services is granted, provided that:\n\n\t1. the below copyright notice appears in all copies and that both the copyright notice and this permission notice appear\n\n\t2. use of such documents from the services is for informational and non-commercial or personal use only and will not be copied or posted on any network computer or broadcast in any media, and\n\n\t3. no modifications of any documents are made.\n\nAccredited educational institutes, such as universities, private/public colleges, and state community colleges, may download and reproduce the documents for distribution in the classroom. Distribution outside the classroom requires express written permission. Use of any other purpose is expressly prohibited by law, and may result in severe civil and criminal penalties. Violators will be prosecuted to the maximum extent possible.Ready Bill and/or its representative suppliers make no representations about the suitability of the information contained in the documents and related graphics published as part of the services for any purpose. All such documents and related graphics are provided "as is" without warranty of any kind. Ready Bill and/or its respective suppliers hereby disclaim all warranties and conditions with regard to this information, including all warranties and conditions of merchantability, whether express, implied or statutory, fitness for a particular purpose, title and non- infringement. In no event shall Ready Bill and/or its respective suppliers be liable for any special, indirect or consequential damages or any damages whatsoever resulting from loss of use, data or profits, whether in an action of contract, negligence or other tortuous action, arising out of or in connection with the use or performance of information available from the services.\n\nThe documents and related graphics published on the services could include technical inaccuracies or typographical errors. Changes are periodically added to the information herein. Ready Bill may make improvements and/or changes in the product(s) and/or the program(s) described herein at any time.\n\nNotices regarding desktop and mobile application, documents and services available on this site in no event shall Ready Bill and/or its respective suppliers be liable for any special, indirect or consequential damages or any damages whatsoever resulting from loss of use, data or profits, whether in an action of contract, negligence or other tortuous action, arising out of or in connection with the use or performance of software, document, provisions of or failure to provide services, or information available from the services.\n\nMaterials provided to Ready Bill or posted at any of its websites Ready Bill does not claim ownership of the material user provide to Ready Bill (including feedback and suggestions) or post, upload, input or submit to any services or its associated services for review by the general public, or by the members of any public or private community, (each a "submission" and collectively "submissions"). However, by posting, uploading, inputting. providing or submitting ("posting") user\'s submission, user is granting Ready Bill its affiliated companies and necessary sub licensees, permission to use user\'s submission in connection with the operation of their internet businesses (including, without limitation, all Ready Bill services), including, without limitation, the license right to; copy, distribute, transmit, publicly display, publicly perform, reproduce, edit, translate and reformat user\'s submission; to publish user\'s name in connection with user\'s submission; and the right to sub-license such rights to any supplier of the services.\n\nNo compensation will be paid with respect to the use of user\'s submission, as provided herein. Ready Bill is under no obligation to post or use any submission user may provide and Ready Bill may remove any submission at any time in its sole discretion. By posting a submission user warrants and represents to own or otherwise control all of the rights to user\'s submission as described in these tou including, without limitation, all the rights necessary for user to provide, post, upload, input or submit the submissions.\n\nIn addition to the warranty and representations set forth above, by posting a submission that contain images, photographs, pictures or that are otherwise graphical in whole or in part ("images"), user warrant and represent that\n\n\t1. user is the copyright owner of such images, or that the copyright owner of such images has granted user permission to use such images or any content and/or images contained in such images consistent with the manner and purpose of user\'s use and as otherwise permitted by these tou and the services,\n\n\t2. user have the rights necessary to grant the licenses and sub licenses described in these tou, and\n\n\t3. that each person depicted in such images, if any, has provided consent to the use of the images as set forth in these tou, including, by way of example, and not as a limitation, the distribution, public display and reproduction of such images.\n\nBy posting images, user is granting\n\n\tto all members of user\'s private community (for each such images available to members of such private community), and/or\n\n\t2. (b) to the general public (for each such images available anywhere on the services, other than a private community), permission to use user\'s images in connection with the use, as permitted by these tou, of any of the services, (including, by way of example, and not as a limitation, making prints and gift items which include such images), and including, without limitation, a non-exclusive, world-wide, royalty-free license to; copy, distribute, transmit, publicly display, publicly perform, reproduce, edit, translate and reformat user\'s images without having user\'s name attached to such images, and the right to sub-license such rights to any supplier of the services.\n\nThe license granted in the preceding sentences for any image will terminate at the time user completely removes such image from the services, provided that, such termination shall not affect any licenses granted in connection with such images prior to the time user completely removes such images. No compensation will be paid with respect to the use of user\'s image.'),
              divider(),
              headingText('Disclaimer of warranty; limitation of liability'),
              divider(),
              subText(
                  'User expressly agrees that use of website and mobile app is at user\'s sole risk. Neither Ready Bill nor its affiliates nor any of their respective employees, agents, third party content providers or licensors warrant that website will be uninterrupted or error free. Nor do they make any warranty as to the results that may be obtained from use of website or mobile app, or as to the accuracy, reliability or content of any information, service, or merchandise provided through website.\n\nWebsite and Mobile app is provided on an "as is" basis without warranties of any kind, either express or implied, including, but not limited to, warranties of title or implied warranties of merchantability or fitness for a particular purpose, other than those warranties which are implied by and incapable of exclusion, restriction or modification under the laws applicable to this agreement.\n\nThis disclaimer of liability applies to any damages or injury caused by any failure of performance, error, omission, interruption, deletion, defect, delay in operation or transmission, computer virus, communication line failure, theft or destruction or unauthorized access to, alteration of, or use of record, whether for breach of contract, tortuous behavior, negligence, or under any other cause of action. User specifically acknowledges that Ready Bill is not liable for the defamatory, offensive or illegal conduct of other users or third-parties and that the risk of injury from the foregoing rests entirely with user.\n\nIn no event will Ready Bill, or any person or entity involved in creating, producing or distributing website or the mobile app, be liable for any damages, including, without limitation, direct, indirect, incidental, special, consequential or punitive damages arising out of the use of or inability to use website or mobile app. User hereby acknowledges that the provisions of this section shall apply to all content on the site.\n\nIn addition to the terms set forth above neither, Ready Bill, nor its affiliates, information providers or content partners shall be liable regardless of the cause or duration, for any errors, inaccuracies, omissions, or other defects in, or untimeliness or unauthenticity of the information contained within website, or for any delay or interruption in the transmission thereof to the user, or for any claims or losses arising therefrom or occasioned thereby. None of the foregoing parties shall be liable for any third-party claims or losses of any nature, including, but not limited to, lost profits, punitive or consequential damages.\n\nForce majeure - neither party will be responsible for any failure or delay in performance due to circumstances beyond its reasonable control, including, without limitation, acts of god, war, riot, embargoes acts of civil or military authorities, fire, floods, accidents, service outages resulting from equipment and/or software failure and/or telecommunications failures, power failures, network failures, failures of third party service providers (including providers of internet services and telecommunications). The party affected by any such event shall notify the other party within a maximum of fifteen (15) days from its occurrence. The performance of this agreement shall then be suspended for as long as any such event shall prevent the affected party from performing its obligations under this agreement.'),
              divider(),
              headingText('Links to third party sites'),
              divider(),
              subText(
                  'The links in this area will let you leave Ready Bill\'s site. The linked sites are not under the control of Ready Bill and Ready Bill is not responsible for the contents of any linked site or any link contained in a linked site, or any changes or updates to such sites. Ready Bill is not responsible for web-casting or any other form of transmission received from any linked site. Ready Bill is providing these links to you only as a convenience, and the inclusion of any link does not imply endorsement by Ready Bill of the site.\n\nReady Bill is a distributor (and not a publisher) of content supplied by third parties and users. Accordingly, Ready Bill has no more editorial control over such content than does a public library, bookstore, or newsstand. Any opinions, advice, statements, services, offers, or other information or content expressed or made available by third parties, including information providers, users or any other user of website, are those of the respective author(s) or distributor(s) and not of Ready Bill. Neither Ready Bill nor any third-party provider of information guarantees the accuracy, completeness, or usefulness or any content, not its merchantability or fitness for any particular purpose.\n\nIn many instances, the content available through website represents the opinions and judgments of the respective information provider, user, or other user not under contract with Ready Bill. Ready Bill neither endorses nor is responsible for the accuracy or reliability of any opinion, advice or statement made on website by anyone other than authorized Ready Bill employee spokespersons while acting in their official capacities. Under no circumstances will Ready Bill be liable for any loss or damage caused by a user\'s reliance on information obtained through website. It is the responsibility of the user to evaluate the accuracy, completeness or usefulness of any information, opinion, advice or other content available through Ready Bill. Please seek the advice of professionals, as appropriate, regarding the evaluation of any specific information, opinion, advice or other content.'),
              divider(),
              headingText('Unsolicited idea submission policy'),
              divider(),
              subText(
                  'Ready Bill or any of is employees do not accept or consider unsolicited ideas, including idea for new advertising campaigns, new promotions, new product or technologies, processes, materials, marketing plans or new product names. Please do not send any original creative artwork, samples, demos, or other works. The sole purpose of this policy is to avoid potential misunderstanding or disputes when Ready Bill\'s products or marketing strategies might seem similar to ideas submitted to Ready Bill. So, please do not send your unsolicited ideas to Ready Bill or anyone at Ready Bill. If, despite our request that you not send us your ideas and materials, you still send them, please understand that Ready Bill makes no assurances that your ideas and materials will be treated as confidential or proprietary.'),
              divider(),
              headingText('Monitoring'),
              divider(),
              subText(
                  'Ready Bill shall have the right, but not the obligation, to monitor the content of website, including chat rooms and forums, to determine compliance with this agreement and any operating rules established by Ready Bill and to satisfy any law, regulation or authorized government request. Ready Bill shall have the right in its sole discretion to edit, refuse to post or remove any material submitted to or posted on website. Without limiting the foregoing, Ready Bill shall have the right to remove any material that Ready Bill, in its sole discretion, finds to be in violation of the provisions hereof or otherwise objectionable.'),
              divider(),
              headingText('Indemnification'),
              divider(),
              subText(
                  'User agrees to defend, indemnify and hold harmless Ready Bill, its affiliates and their respective directors, officers, employees and agents from and against all claims and expenses, including attorneys\' fees, arising out of the use of Ready Bill by user or user\'s account.'),
              divider(),
              headingText('Termination'),
              divider(),
              subText(
                  'Either Ready Bill or user may terminate this agreement at any time. Without limiting the foregoing, Ready Bill shall have the right to immediately terminate user\'s account in the event of any conduct by user which Ready Bill, in its sole discretion, considers to be unacceptable, or in the event of any breach by user of this agreement.'),
              divider(),
              headingText('Miscellaneous'),
              subText(
                  'This agreement and any operating rules for website established by Ready Bill constitute the entire agreement of the parties with respect to the subject matter hereof, and supersede all previous written or oral agreements between the parties with respect to such subject matter. This agreement shall be constructed in accordance with the laws of the Assam, india, without regard to its conflict of laws rules. No wavier by either party of any breach or default here-under shall be deemed to be a waiver of any preceding or subsequent breach or default. The section headings used herein are for convenience only and shall not be given any legal import.'),
              divider(),
              headingText('Copyright notice'),
              divider(),
              subText(
                  'Ready Bill, its logos are trademarks of Ready Bill all rights reserved. All other trademarks appearing on Ready Bill are the property of their respective owners.'),
              divider(),
              headingText('Trademarks'),
              divider(),
              subText(
                  'The names of actual companies and products mentioned herein may be the trademarks of their respective owners. The example companies, organization, products, domain names, email addresses, logos, people and events depicted herein are fictitious. No association with any real company, organization, product, domain name, email address, logo, person, or event is intended or should be inferred. Any rights not expressly granted herein are reserved.'),
              const SizedBox(
                height: 60,
              ),
              const Text(
                'Copyright 2024 © Ready Bill. Designed and developed by Alegra Labs',
                style: TextStyle(color: black, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
