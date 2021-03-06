# frozen_string_literal: true

# Copyright 2020 Matthew B. Gray
# Copyright 2020 Victoria Garcia
# Copyright 2021 Fred Bauer - Hard-coded for no retros, because there's no localization for this.
#
# Licensed under the Apache License, Version 2.0 

class NominationMailer < ApplicationMailer
  include ApplicationHelper

  default from: $member_services_email

  def nomination_ballot(reservation)
    @worldcon_basic_greeting = worldcon_basic_greeting
    @previous_worldcon_public_name = previous_worldcon_public_name
    @worldcon_year_before = worldcon_year_before
    @worldcon_public_name = worldcon_public_name
    @worldcon_year = worldcon_year
    @retro_hugo_75_ago = retro_hugo_75_ago
    @organizers_names_for_signature = organizers_names_for_signature
    @detail = reservation.active_claim.contact
    nominated_categories = Category.joins(nominations: :reservation).where(reservations: {id: reservation})

    builder = MemberNominationsByCategory.new(
      reservation: reservation,
      categories: nominated_categories.order(:order, :id),
    )
    builder.from_reservation
    @nominations_by_category = builder.nominations_by_category

    mail(
#      subject: "Your #{worldcon_year} Hugo and #{retro_hugo_75_ago} Retro Hugo Nominations Ballot",
      subject: "Your #{worldcon_year} Hugo Nominations Ballot", #for DC
      to: reservation.user.email,
      from: "Hugo Awards #{worldcon_year} <#{email_hugo_help}>"
    )
  end

  def nomination_notice_chicago
    @worldcon_greeting_sentence_excited = worldcon_greeting_sentence_excited
    @worldcon_public_name = worldcon_public_name
    @hugo_nom_deadline = hugo_nom_deadline
    @previous_worldcon_public_name = previous_worldcon_public_name
    @worldcon_year_before = worldcon_year_before
    @worldcon_year = worldcon_year
    @start_day_informal = start_day_informal
    @end_day_informal = end_day_informal
    @retro_hugo_75_ago = retro_hugo_75_ago
    @mailto_hugo_help = mailto_hugo_help
    @hugo_help_email = email_hugo_help
    @hugo_ballot_download_a4 = hugo_ballot_download_a4
    @hugo_ballot_download_letter = hugo_ballot_download_letter
    @wsfs_constitution_link = @wsfs_constitution_link
    @organizers_names_for_signature = organizers_names_for_signature
  end

  def nominations_open_dublin(user:)
    @user = user
    @reservations = user.reservations.joins(:membership).where(memberships: {name: :dublin_2019})

    @account_numbers = account_numbers_from(@reservations)
    if @account_numbers.count == 1
      subject = "CoNZealand: Hugo Nominations are now open for account #{@account_numbers.first}"
    else
      subject = "CoNZealand: Hugo Nominations are now open for accounts #{@account_numbers.to_sentence}"
    end

    mail(to: user.email, from: "hugohelp@conzealand.nz", subject: subject)
  end

  def nominations_open_conzealand(user:)
    @user = user
    @reservations = user.reservations.joins(:membership).merge(Membership.can_nominate)

    account_numbers = account_numbers_from(@reservations)
    if account_numbers.count == 1
      subject = "CoNZealand: Hugo Nominations are now open for member #{account_numbers.first}"
    else
      subject = "CoNZealand: Hugo Nominations are now open for members #{account_numbers.to_sentence}"
    end

    mail(to: user.email, from: "hugohelp@conzealand.nz", subject: subject)
  end

  def nominations_open_dc(user:)
    @user = user
    @reservations = user.reservations.joins(:membership).merge(Membership.can_nominate)

    account_numbers = account_numbers_from(@reservations)
    if account_numbers.count == 1
      subject = "DisCon III: Hugo Nominations are now open for member #{account_numbers.first}"
    else
      subject = "DisCOn III: Hugo Nominations are now open for members #{account_numbers.to_sentence}"
    end

    mail(to: user.email, from: "hugohelp@discon3.org", subject: subject)
  end

  def nominations_reminder_2_weeks_left_conzealand(email:)
    user = User.find_by!(email: email)
    reservations_that_can_nominate = user.reservations.joins(:membership).merge(Membership.can_nominate)

    if reservations_that_can_nominate.none?
      return
    end

    account_numbers = account_numbers_from(reservations_that_can_nominate)
    if account_numbers.count == 1
      subject = "2 weeks to go! Hugo Award Nominating Reminder for member #{account_numbers.first}"
    else
      subject = "2 weeks to go! Hugo Award Nominating Reminder for members #{account_numbers.to_sentence}"
    end

    @details = Detail.where(claim_id: user.active_claims)

    mail(to: user.email, from: "hugohelp@conzealand.nz", subject: subject)
  end

  def nominations_reminder_2_weeks_left_conzealand(email:)
    user = User.find_by!(email: email)
    reservations_that_can_nominate = user.reservations.joins(:membership).merge(Membership.can_nominate)

    if reservations_that_can_nominate.none?
      return
    end

    account_numbers = account_numbers_from(reservations_that_can_nominate)
    if account_numbers.count == 1
      subject = "2 weeks to go! Hugo Award Nominating Reminder for member #{account_numbers.first}"
    else
      subject = "2 weeks to go! Hugo Award Nominating Reminder for members #{account_numbers.to_sentence}"
    end

    @details = Detail.where(claim_id: user.active_claims)

    mail(to: user.email, from: "hugohelp@conzealand.nz", subject: subject)
  end

  def nominations_reminder_2_weeks_left_dublin(email:)
    user = User.find_by!(email: email)
    reservations_that_can_nominate = user.reservations.joins(:membership).merge(Membership.can_nominate)

    if reservations_that_can_nominate.none?
      return
    end

    account_numbers = account_numbers_from(reservations_that_can_nominate)
    if account_numbers.count == 1
      subject = "2 weeks to go! Hugo Award Nominating Reminder for account #{account_numbers.first}"
    else
      subject = "2 weeks to go! Hugo Award Nominating Reminder for accounts #{account_numbers.to_sentence}"
    end

    @details = Detail.where(claim_id: user.active_claims)

    mail(to: user.email, from: "hugohelp@conzealand.nz", subject: subject)
  end

  # Unlike the other templates the only difference in this is the subject line, hence a single mailer
  # NOTE THIS IS NOT TRUE.  The mailer has Retro Hugos hard-coded, which may not apply to all conventions.  *****FIX THIS*****
  def nominations_reminder_3_days_left(email:)
    @worldcon_greeting_init_caps = worldcon_greeting_init_caps
    @hugo_nom_deadline = hugo_nom_deadline
    @member_login_url = member_login_url
    @hugo_ballot_pub_month = hugo_ballot_pub_month
    @worldcon_public_name = worldcon_public_name
    @start_day_informal = start_day_informal
    @end_day_informal = end_day_informal
    @worldcon_year = worldcon_year
    @worldcon_year_before = worldcon_year_before
    @retro_hugo_75_ago = retro_hugo_75_ago
    @email_hugo_help = email_hugo_help
    @hugo_ballot_download_a4 = hugo_ballot_download_a4
    @hugo_ballot_download_letter = hugo_ballot_download_letter
    @wsfs_constitution_link = wsfs_constitution_link
    @organizers_names_for_signature = organizers_names_for_signature

    user = User.find_by!(email: email)

    if user.reservations.none?
      return
    end

    account_numbers = account_numbers_from(user.reservations)
    conzealand = conzealand_memberships.where(reservations: {id: user.reservations}).any?

    if account_numbers.count == 1 && conzealand
      subject = "Hugo Nominations Close in 3 Days! for member #{account_numbers.first}"
    elsif conzealand
      subject = "Hugo Nominations Close in 3 Days! for members #{account_numbers.to_sentence}"
    elsif account_numbers.count == 1
      subject = "Hugo Nominations Close in 3 Days! for account #{account_numbers.first}"
    else
      subject = "Hugo Nominations Close in 3 Days! for accounts #{account_numbers.to_sentence}"
    end

    @details = Detail.where(claim_id: user.active_claims)

    mail(to: user.email, from: "#{hugo_help_email}", subject: subject)
  end

  private

  # Given reservations, gets membership numbers and puts a pound in front of each
  def account_numbers_from(reservations)
    reservations.pluck(:membership_number).map { |n| "##{n}" }
  end

  def conzealand_memberships
    Membership.can_nominate.where.not(name: :dublin).joins(:reservations)
  end

  def chicago_memberships
    # TODO: Write this query
  end
end
