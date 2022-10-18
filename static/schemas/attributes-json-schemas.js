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
                	  { "type": "help", "helpvalue": "<div class=\"alert alert-info\">Aqui se especifican los datos detallados del perfil de repositorio.</div>"},	
                	  
                          { type: "submit", title: "Guardar cambios" },
                           {
                        "type": "tabs",
                        "tabs": [
                          {
                            "title": "Datos principales",
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
                      { type: "submit", title: "Guardar cambios" }
                      ],
                  schema: {
                          type: "object",
                              properties: {
                                  institution_type: {type: "string", default: "", title: "Tipo de institución", "enum": ["Privada", "Gobierno", "ONG", "Universidad"]},
                                  institution_url: {type: "string", default: "", title: "URL de la institución"},
                                  repository_type:{ type: "string", default: "", title: "Tipo de repositorio", "enum": ["Institucional", "Temático", "Portal de revistas"]},
                                  repository_url:{ type: "string", default: "", title: "URL del repositorio"},
                                  oai_url:{ type: "string", default: "", title: "URL OAI"},
                                  lastname_firstname_responsible:{ type: "string", default: "", title: "Apellido y nombre del responsable"},
                                  responsible_charge:{ type: "string", default: "", title: "Cargo del responsable"},
                                  contact_email: {type: "string", default: "", title: "E-mail de contacto"},
                                  country:{ type: "string", default: "", title: "País", "enum": [ "Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda", "Argentina", "Armenia", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Brasil", "Brunei", "Bulgaria", "Burkina Faso", "Burundi", "Côte d'Ivoire", "Cabo Verde", "Cambodia", "Cameroon", "Canada", "Central African Republic", "Chad", "Chile", "China", "Colombia", "Comoros", "Congo (Congo-Brazzaville)", "Costa Rica", "Croatia", "Cuba", "Cyprus", "Czechia (Czech Republic)", "Democratic Republic of the Congo", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Eswatini (fmr. \"Swaziland\")", "Ethiopia", "Fiji", "Finland", "France", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Greece", "Grenada", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Holy See", "Honduras", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Mauritania", "Mauritius", "México", "Micronesia", "Moldova", "Monaco", "Mongolia", "Montenegro", "Morocco", "Mozambique", "Myanmar (formerly Burma)", "Namibia", "Nauru", "Nepal", "Netherlands", "New Zealand", "Nicaragua", "Niger", "Nigeria", "North Korea", "North Macedonia", "Norway", "Oman", "Pakistan", "Palau", "Palestine State", "Panamá", "Papua New Guinea", "Paraguay", "Perú", "Philippines", "Poland", "Portugal", "Qatar", "Romania", "Russia", "Rwanda", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Korea", "South Sudan", "Spain", "Sri Lanka", "Sudan", "Suriname", "Sweden", "Switzerland", "Syria", "Tajikistan", "Tanzania", "Thailand", "Timor-Leste", "Togo", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States of America", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela", "Vietnam", "Yemen", "Zambia", "Zimbabwe"]},
                                  city:{ type: "string", default: "", title: "Ciudad"},
                                  phone:{ type: "string", default: "", title: "Teléfono"},
                                  software:{ type: "string", default: "", title: "Software", "enum": ["DSpace", "Greenstone", "Eprints", "OJS", "Otro"]},
                                  journal_title: {type: "string", default: "", title: "Título de la revista"},
                                  doi:{ type: "string", default: "", title: "Digital Object Identifier (DOI)"},
                                  issn:{ type: "string", default: "", title: "ISSN"},
                                  issn_l:{ type: "string", default: "", title: "ISSN-L"},
                                  repository_id:{ type: "string", default: "", title: "ID del repositorio"},
                              }
                          } /* fin schema */
  }, /** fin de profile */
]; // ***** fin de _PROFILES ******///


  /** mapeo de las definiciones de reglas a un objeto * */
var profiles_defs_by_class = {};


  $.map( _PROFILES, function(profile, i ) { profiles_defs_by_class[profile.className] = profile; });

  /** export del objeto con las definiciones de reglas * */
  this.profileDefinitionByClassName = profiles_defs_by_class;
  this.profileDefinitionList = _PROFILES;
});
