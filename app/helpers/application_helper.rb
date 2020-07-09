# frozen_string_literal: true

# Copyright 2019 AJ Esler
# Copyright 2020 Matthew B. Gray
# Copyright 2020 Victoria Garcia
# Copyright 2020 Steven Ensslen
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module ApplicationHelper

  include ThemeConcern

  DEFUALT_NAV_CLASSES = %w(navbar navbar-dark shadow-sm).freeze

  # The root page has an expanded menu
  def navigation_classes
    if request.path == root_path
      DEFUALT_NAV_CLASSES
    else
      DEFUALT_NAV_CLASSES + %w(bg-dark)
    end.join(" ")
  end

  # These match i18n values set in config/locales
  # see Membership#all_rights
  def membership_right_description(membership_right, reservation)
    description = I18n.t(:description, scope: membership_right)
    if match = membership_right.match(/rights\.(.*)\.nominate\z/)
      election_i18n_key = match[1]
      link_to description, reservation_nomination_path(reservation_id: reservation, id: election_i18n_key)
    elsif match = membership_right.match(/rights\.(.*)\.nominate_only\z/)
      election_i18n_key = match[1]
      link_to description, reservation_nomination_path(reservation_id: reservation, id: election_i18n_key)
    elsif finalists_loaded? && match = membership_right.match(/rights\.(.*)\.vote\z/)
      election_i18n_key = match[1]
      link_to description, reservation_finalist_path(reservation_id: reservation, id: election_i18n_key)
    else
      description
    end
  end

  def fuzzy_time(as_at)
    content_tag(
      :span,
      fuzzy_time_in_words(as_at),
      title: as_at&.iso8601 || "Time not set",
    )
  end

  def fuzzy_time_in_words(as_at)
    if as_at.nil?
      "open ended"
    elsif as_at < Time.now
      "#{time_ago_in_words(as_at)} ago"
    else
      "#{time_ago_in_words(as_at)} from now"
    end
  end

  def markdown
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
  end

  def worldcon_contact_form
    ApplicationHelper.theme_contact_form
  end

  def worldcon_public_name
    ApplicationHelper.theme_con_public_name
  end

  def worldcon_public_name_spaceless
    ApplicationHelper.theme_con_public_name.remove(" ");
  end

  def worldcon_year
    ouryear = ApplicationHelper.theme_con_year
  end

  def worldcon_year_before
    ouryear = ((ApplicationHelper.theme_con_year.to_i) - 1).to_s
  end

  def worldcon_year_after
    ouryear = ((ApplicationHelper.theme_con_year.to_i) + 1).to_s
  end

  def site_selection_year
    ouryear = ((ApplicationHelper.theme_con_year.to_i) + 2).to_s
  end

  def retro_hugo_years
    #TODO: Make a mechanism to populate this array
    []
  end

  def retro_hugo?
    retro_hugo.length > 0
  end

  def number_of_retro_hugos
    retro_hugo_years.length
  end

  def email_hugo_help
    ouremail = ApplicationHelper.theme_hugo_help_email
  end

  def worldcon_basic_greeting
    ourgreeting = ApplicationHelper.theme_greeting
    return ourgreeting
  end

  def worldcon_greeting_init_caps
    ourgreeting = ApplicationHelper.theme_greeting.split.map{|word| word.capitalize}.inject { |accum, w| accum.concat(" ").concat(w) }.strip
    return ourgreeting
  end

  def worldcon_greeting_sentence
    ourgreeting = ApplicationHelper.theme_greeting.capitalize.concat(".")
    return ourgreeting
  end

  def worldcon_greeting_sentence_excited
    ourgreeting = ApplicationHelper.theme_greeting.capitalize.concat("!")
    return ourgreeting
  end

  def worldcon_city
    ourcity = ApplicationHelper.theme_con_city.split.map{|word| word.capitalize}.inject { |accum, w| accum.concat(" ").concat(w) }.strip
    binding.pry
    return ourcity
  end

  def worldcon_country
    ourcountry = ApplicationHelper.theme_con_country.split.map{|word| word.capitalize}.inject { |accum, w| accum.concat(" ").concat(w) }.strip
    binding.pry
    return ourcountry
  end

  def worldcon_url_tos
    ApplicationHelper.theme_con_tos_url
  end

  def worldcon_url_privacy
    ApplicationHelper.theme_con_privacy_url
  end

  def worldcon_url_volunteering
    ApplicationHelper.theme_con_volunteering_url
  end

  def worldcon_url_homepage
    ApplicationHelper.theme_con_homepage_url
  end

  def worldcon_previous_city
    ApplicationHelper.theme_con_city_previous
  end

  def finalists_loaded?
    @voting_open ||= Finalist.count > 0
  end

  def hugo_nom_start
    $nomination_opens_at.strftime("%A %-d %B %Y, %H:%M %p %Z")
  end

  def hugo_nom_deadline
    $hugo_closed_at.strftime("%A %-d %B %Y, %H:%M %p %Z")
  end

  def hugo_vote_deadline
    $hugo_closed_at.strftime("%A %-d %B %Y, %H:%M %p %Z")
  end

  def hugo_ballot_pub_month
    rough_guess_month = Date._parse($hugo_closed_at.to_s)[:mon] + 1
    rough_guess_year = Date._parse($hugo_closed_at.to_s)[:year]
    if (rough_guess_month > 12)
      rough_guess_month = rough_guess_month - 12
      rough_guess_year = rough_guess_year + 1
    end
    return "#{Date::MONTHNAMES[rough_guess_month]} #{rough_guess_year}"
  end

  def virtual_con_language
    (ApplicationHelper.theme_con_year == "2020") ? "the interactive virtual" : ""
  end

  def interpolation_vals
    ourHash = {
      :email_hugo_help => email_hugo_help,
      :hugo_noms_open => hugo_nom_start,
      :hugo_nom_dl => hugo_nom_deadline,
      :hugo_vote_dl => hugo_vote_deadline,
      :hugo_ballot_month => hugo_ballot_pub_month,
      :virtual_language => virtual_con_lang,
      :worldcon_country => worldcon_country,
      :worldcon_greeting_sentence => worldcon_greeting_sentence,
      :worldcon_greeting_sentence_excited => worldcon_greeting_sentence_excited,
      :worldcon_hugo_email => email_hugo_help,
      :worldcon_previous_city => worldcon_previous_city,
      :worldcon_public_name => worldcon_public_name,
      :worldcon_year => worldcon_year,
      :worldcon_year_after => worldcon_year_after,
      :worldcon_year_before => worldcon_year_before,
      :retro_hugo_year => retro_hugo_year,
      :virtual_con_language => virtual_con_language
    }
    return ourHash
  end

end
