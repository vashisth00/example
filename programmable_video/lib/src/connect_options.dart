part of twilio_programmable_video;

/// Represents options when connecting to a [Room].
class ConnectOptions {
  /// This Access Token is the credential you must use to identify and authenticate your request.
  /// More information about Access Tokens can be found here: https://www.twilio.com/docs/video/tutorials/user-identity-access-tokens
  final String accessToken;

  /// The name of the room.
  final String roomName;

  /// The region of the signaling Server the Client will use.
  final Region region;

  /// Enable detection of the loudest audio track
  final bool enableDominantSpeaker;

  /// Set preferred audio codecs.
  final List<AudioCodec> preferredAudioCodecs;

  /// Set preferred video codecs.
  final List<VideoCodec> preferredVideoCodecs;

  /// Audio tracks that will be published upon connection.
  final List<LocalAudioTrack> audioTracks;

  /// Data tracks that will be published upon connection.
  final List<LocalDataTrack> dataTracks;

  /// Video tracks that will be published upon connection.
  final List<LocalVideoTrack> videoTracks;

  /// Choosing between `subscribe-to-all` or `subscribe-to-none` subscription rule
  final bool enableAutomaticSubscription;

  ConnectOptions(
    this.accessToken, {
    this.audioTracks,
    this.dataTracks,
    this.preferredAudioCodecs,
    this.preferredVideoCodecs,
    this.region,
    this.roomName,
    this.videoTracks,
    this.enableDominantSpeaker,
    this.enableAutomaticSubscription,
  })  : assert(accessToken != null),
        assert(accessToken.isNotEmpty),
        assert((audioTracks != null && audioTracks.isNotEmpty) || audioTracks == null),
        assert((dataTracks != null && dataTracks.isNotEmpty) || dataTracks == null),
        assert((preferredAudioCodecs != null && preferredAudioCodecs.isNotEmpty) || preferredAudioCodecs == null),
        assert((preferredVideoCodecs != null && preferredVideoCodecs.isNotEmpty) || preferredVideoCodecs == null),
        assert((videoTracks != null && videoTracks.isNotEmpty) || videoTracks == null);

  /// Create a [ConnectOptionsModel] from properties.
  ConnectOptionsModel _toModel() {
    final audioTrackModels = audioTracks == null
        ? null
        : List<LocalAudioTrackModel>.from(
            audioTracks.map<LocalAudioTrackModel>(
              (e) => e._toModel(),
            ),
          );

    final dataTrackModels = dataTracks == null
        ? null
        : List<LocalDataTrackModel>.from(
            dataTracks.map<LocalDataTrackModel>(
              (e) => e._toModel(),
            ),
          );

    final videoTrackModels = videoTracks == null
        ? null
        : List<LocalVideoTrackModel>.from(
            videoTracks.map<LocalVideoTrackModel>(
              (e) => e._toModel(),
            ),
          );

    return ConnectOptionsModel(
      accessToken,
      audioTracks: audioTrackModels,
      dataTracks: dataTrackModels,
      videoTracks: videoTrackModels,
      enableAutomaticSubscription: enableAutomaticSubscription,
      enableDominantSpeaker: enableDominantSpeaker,
      preferredAudioCodecs: preferredAudioCodecs,
      preferredVideoCodecs: preferredVideoCodecs,
      region: region,
      roomName: roomName,
    );
  }
}
