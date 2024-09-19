/* 
 *  This is the default license template.
 *  
 *  File: attributes-json-schemas.js
 *  Author: lmatas
 *  Copyright (c) 2022 lmatas
 *  
 *  To edit this license information: Press Ctrl+Shift+P and press 'Create new License Template...'.
 */

angular.module('attributes.json.schemas', []).service('JSONAttributesSchemas', function() {

  var _PROFILES = [

  {
                  name : "LaReferencia Profile",
                  className: "org.lareferencia.backend.network.LAReferenciaNetworkAttributes",
                  form: [
                      { "type": "help", "helpvalue": "<div class=\"alert alert-info\">Here you specify the detailed data of the repository profile.</div>"},	
                      
                          { type: "submit", title: "Save changes" },
                           {
                        "type": "tabs",
                        "tabs": [
                          {
                            "title": "Main data",
                            "items": [
                                    "institution_type",
                                    "institution_url",
                                    "repository_type",
                                    "repository_url",
                                    "oai_url",
                                    "lastname_firstname_responsible",
                                    "responsible_charge",
                                    "contact_email",
                                    "country",
                                    "city",
                                    "phone",
                                    "software",
                                    "journal_title",
                                    "doi",
                                    "issn",
                                    "issn_l",
                                    "repository_id",
                            ]
                          },
                        ]
                      },
                      { type: "submit", title: "Save changes" }
                      ],
                  schema: {
                          type: "object",
                              properties: {
                                  institution_type: {type: "string", default: "", title: "Institution type", "enum": ["Private", "Government", "NGO", "University"]},
                                  institution_url: {type: "string", default: "", title: "Institution URL"},
                                  repository_type:{ type: "string", default: "", title: "Repository type", "enum": ["Institutional", "Thematic", "Journal portal"]},
                                  repository_url:{ type: "string", default: "", title: "Repository URL"},
                                  oai_url:{ type: "string", default: "", title: "OAI URL"},
                                  lastname_firstname_responsible:{ type: "string", default: "", title: "Last name and first name of the responsible"},
                                  responsible_charge:{ type: "string", default: "", title: "Responsible charge"},
                                  contact_email: {type: "string", default: "", title: "Contact email"},
                                  country:{ type: "string", default: "", title: "Country", "enum": [ "Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda", "Argentina", "Armenia", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina Faso", "Burundi", "Côte d'Ivoire", "Cabo Verde", "Cambodia", "Cameroon", "Canada", "Central African Republic", "Chad", "Chile", "China", "Colombia", "Comoros", "Congo (Congo-Brazzaville)", "Costa Rica", "Croatia", "Cuba", "Cyprus", "Czechia (Czech Republic)", "Democratic Republic of the Congo", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Eswatini (fmr. \"Swaziland\")", "Ethiopia", "Fiji", "Finland", "France", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Greece", "Grenada", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Holy See", "Honduras", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Mauritania", "Mauritius", "Mexico", "Micronesia", "Moldova", "Monaco", "Mongolia", "Montenegro", "Morocco", "Mozambique", "Myanmar (formerly Burma)", "Namibia", "Nauru", "Nepal", "Netherlands", "New Zealand", "Nicaragua", "Niger", "Nigeria", "North Korea", "North Macedonia", "Norway", "Oman", "Pakistan", "Palau", "Palestine State", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Poland", "Portugal", "Qatar", "Romania", "Russia", "Rwanda", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Korea", "South Sudan", "Spain", "Sri Lanka", "Sudan", "Suriname", "Sweden", "Switzerland", "Syria", "Tajikistan", "Tanzania", "Thailand", "Timor-Leste", "Togo", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States of America", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela", "Vietnam", "Yemen", "Zambia", "Zimbabwe"]},
                                  city:{ type: "string", default: "", title: "City"},
                                  phone:{ type: "string", default: "", title: "Phone"},
                                  software:{ type: "string", default: "", title: "Software", "enum": ["DSpace", "Greenstone", "Eprints", "OJS", "Other"]},
                                  journal_title: {type: "string", default: "", title: "Journal title"},
                                  doi:{ type: "string", default: "", title: "Digital Object Identifier (DOI)"},
                                  issn:{ type: "string", default: "", title: "ISSN"},
                                  issn_l:{ type: "string", default: "", title: "ISSN-L"},
                                  repository_id:{ type: "string", default: "", title: "Repository ID"},
                              }
                          } /* end schema */
  }, /** end of profile */
]; // ***** end of _PROFILES ******///


  /** mapeo de las definiciones de reglas a un objeto * */
var profiles_defs_by_class = {};


  $.map( _PROFILES, function(profile, i ) { profiles_defs_by_class[profile.className] = profile; });

  /** export del objeto con las definiciones de reglas * */
  this.profileDefinitionByClassName = profiles_defs_by_class;
  this.profileDefinitionList = _PROFILES;
});
