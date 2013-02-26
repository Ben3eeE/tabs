$ = require 'jquery'
{View} = require 'space-pen'
fs = require 'fs'

module.exports =
class TabView extends View
  @content: ->
    @li class: 'tab sortable', =>
      @span class: 'title', outlet: 'title'
      @span class: 'close-icon'

  initialize: (@item, @pane) ->
    @item.on? 'title-changed', => @updateTitle()
    @updateTitle()
#     @buffer = @editSession.buffer
#     @subscribe @buffer, 'path-changed', => @updateFileName()
#     @subscribe @buffer, 'contents-modified', => @updateModifiedStatus()
#     @subscribe @buffer, 'saved', => @updateModifiedStatus()
#     @subscribe @buffer, 'git-status-changed', => @updateModifiedStatus()
#     @subscribe @editor, 'editor:edit-session-added', => @updateFileName()
#     @subscribe @editor, 'editor:edit-session-removed', => @updateFileName()
#     @updateFileName()
#     @updateModifiedStatus()

  updateTitle: ->
    return if @updatingTitle
    @updatingTitle = true

    title = @item.getTitle()
    useLongTitle = false
    for tab in @getSiblingTabs()
      if tab.item.getTitle() is title
        tab.updateTitle()
        useLongTitle = true
    title = @item.getLongTitle?() ? title if useLongTitle

    @title.text(title)
    @updatingTitle = false

  getSiblingTabs: ->
    @siblings('.tab').views()

  updateModifiedStatus: ->
    if @buffer.isModified()
      @toggleClass('file-modified') unless @isModified
      @isModified = true
    else
      @removeClass('file-modified') if @isModified
      @isModified = false

  updateFileName: ->
    fileNameText = @editSession.buffer.getBaseName()
    if fileNameText?
      duplicates = @editor.getEditSessions().filter (session) -> fileNameText is session.buffer.getBaseName()
      if duplicates.length > 1
        directory = fs.base(fs.directory(@editSession.getPath()))
        fileNameText = "#{fileNameText} - #{directory}" if directory
    else
      fileNameText = 'untitled'

    @fileName.text(fileNameText)
    @fileName.attr('title', @editSession.getPath())