# frozen_string_literal: true

# Copyright 2020 Steven Ensslen
# Copyright 2020 Matthew B. Gray
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

require "aws-sdk"

class HugoPacketController < ApplicationController
  Packet = Struct.new(:s3_client, :prefix, :blob) do
    include ActionView::Helpers::NumberHelper

    delegate :size, :key, to: :blob

    def downloadable?
      size > 0
    end

    def signed_url
      object = Aws::S3::Object.new(
        key: key,
        bucket_name: ENV['HUGO_PACKET_BUCKET'],
        client: s3_client,
      )
      object.presigned_url(:get, expires_in: 1.hour.to_i)
    end

    def file_name
      key.sub(prefix + '/', '')
    end

    def download_size
      number_to_human_size(size)
    end
  end

  before_action :check_access!

  def index
    s3_client = Aws::S3::Client.new
    list_objects = s3_client.list_objects_v2(
      bucket: ENV["HUGO_PACKET_BUCKET"],
      prefix: ENV["HUGO_PACKET_PREFIX"],
    )

    @packets = list_objects.contents.map do |blob|
      Packet.new(s3_client, list_objects.prefix, blob)
    end

    @blobs = list_objects
  end

  private

  def check_access!
    if !user_signed_in?
      flash["notice"] = "Please log in to download the hugo packet"
      redirect_to root_path
      return
    end

    if current_user.reservations.none?(&:can_vote?)
      flash["notice"] = "Please upgrade one of your memberships to download the hugo packet"
      redirect_to reservations_path
      return
    end
  end
end
