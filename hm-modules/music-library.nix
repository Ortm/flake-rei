# The music library — what mpd indexes and rmpc browses (hm-modules/sound/mpd.nix
# points its music_directory at ~/Music).
#
# The big lossless collection lives on the external SSD, which /etc/fstab mounts
# at /mnt/ssd. Linking it in instead of copying keeps one copy of ~6 GB on disk:
# the entry below is a plain symlink to that path (mkOutOfStoreSymlink), not a
# copy into the store. mpd follows it out of the box — follow_outside_symlinks
# defaults to yes — so the SSD's tracks appear in the library like any other.
# While the SSD is unmounted the link dangles: mpd logs that and carries on.
#
# The player's copy is not linked in: ym-player-sync mirrors the playlist onto
# the player from ~/Music, so the library is the source, not the player.
{ config, ... }:

{
  home.file."Music/ssd".source = config.lib.file.mkOutOfStoreSymlink "/mnt/ssd/music";
}
