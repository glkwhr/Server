import { TRPGRouter, ModelAccess } from 'trpg/core';
import { ssoAuth, ssoInfo } from 'packages/Player/lib/middleware/auth';
import { PlayerJWTPayload } from 'packages/Player/types/player';
import { PlayerUser } from 'packages/Player/lib/models/user';
import _ from 'lodash';
import { ActorActor } from '../models/actor';

const actorRouter = new TRPGRouter<{
  player?: PlayerJWTPayload;
}>();

actorRouter.get('/list', ssoAuth(), async (ctx) => {
  const playerInfo = ctx.state.player;

  const user = await PlayerUser.findByUUID(playerInfo.uuid);
  const actors = await _.invoke(user, 'getActors');

  ctx.body = { list: actors };
});

actorRouter.post('/create', ssoAuth(), async (ctx) => {
  const playerInfo = ctx.state.player;
  const { name, desc, avatar, templateUUID, actorInfo } = ctx.request.body;

  if (!name || !templateUUID) {
    throw new Error('缺少必要字段');
  }

  if (!_.isObject(actorInfo)) {
    throw new Error('人物卡数据格式不正确');
  }

  const user = await PlayerUser.findByUUID(playerInfo.uuid);

  const actor: ActorActor = await ActorActor.create({
    name,
    desc,
    avatar,
    template_uuid: templateUUID,
    info: actorInfo,
  });
  await actor.setOwner(user);

  ctx.body = { actor };
});

actorRouter.get('/:actorUUID/detail', async (ctx) => {
  const actorUUID = ctx.params.actorUUID;

  const actor = await ActorActor.findByUUID(actorUUID);

  ctx.body = { actor };
});

actorRouter.get('/:actorUUID/access', ssoInfo(), async (ctx) => {
  const actorUUID = ctx.params.actorUUID;

  if (_.isNil(ctx.state.player)) {
    ctx.body = {
      access: {
        editable: false,
        removeable: false,
      } as ModelAccess,
    };

    return;
  }

  const actor = await ActorActor.findByUUID(actorUUID);
  const owner: PlayerUser = await actor.getOwner();

  if (owner.uuid === _.get(ctx.state, 'player.uuid')) {
    ctx.body = {
      access: {
        editable: true,
        removeable: true,
      } as ModelAccess,
    };
  } else {
    ctx.body = {
      access: {
        editable: false,
        removeable: false,
      } as ModelAccess,
    };
  }
});

export default actorRouter;
