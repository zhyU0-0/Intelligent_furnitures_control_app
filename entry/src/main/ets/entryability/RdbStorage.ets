import relationalStore from '@ohos.data.relationalStore';

import { air_condition, Furniture, room } from '../tool/classes';


// 定义数据库操作类
export class RoomDatabase {
  private context: Context; // 这里假设你有合适的 Context 对象
  private rdbStore: relationalStore.RdbStore | null = null;
  private readonly DB_NAME = 'room.db';
  private readonly TABLE_NAME = 'Room';


  constructor(context: Context) {
    this.context = context;
    this.initDatabase();
  }

  // 初始化数据库
  private async initDatabase() {

    try {
      this.rdbStore = await relationalStore.getRdbStore(globalThis.getContext(), {
        name: 'room_store.db',
        securityLevel: relationalStore.SecurityLevel.S1
      });
      // 创建 Furniture 表
      this.rdbStore.executeSql('CREATE TABLE IF NOT EXISTS Furniture (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE, switch INTEGER,roomId INTEGER,type_id INTEGER UNIQUE)');
      // 创建 Room 表
      this.rdbStore.executeSql('CREATE TABLE IF NOT EXISTS Room (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE)');
      console.log('Database initialized and table created.');
    } catch (err) {
      console.error(`Failed to initialize database: ${err.message}`);
    }
  }

  // 插入书籍数据
  async insertRoom(room: room) {
    try {
      const roomId = await this.rdbStore?.insert(this.TABLE_NAME, {
        'name': room.name
      });

      for (const furniture of room.furniture_s) {
        const furnitureId = await this.rdbStore?.insert('Furniture', {
          'name': furniture.name,
          'switch': furniture.switch,
          'roomId': roomId,
          'type_id': furniture.type_id
        })
      }

      return 1
    } catch (err) {
      if (err.message.includes('UNIQUE constraint failed')) {
        console.error(`Failed to insert room: Name ${room.name} already exists.`);
        return -1
      } else {
        console.error(`Failed to insert room: ${err.message}`);
        return -1
      }
    }
  }

  async insertFuByRoomId(roomId: number, f_name: string, type_id: number) {
    try {
      const furnitureId = await this.rdbStore?.insert('Furniture', {
        'name': f_name + ':' + roomId,
        'switch': 0,
        'roomId': roomId,
        'type_id': type_id

      });

      console.log('Room inserted successfully.');
      return 1
    } catch (err) {
      if (err.message.includes('UNIQUE constraint failed')) {
        console.error(`Failed to insert roomsfurniture: Name ${f_name} already exists.`);
        return -1
      } else {
        console.error(`Failed to insert furniture: ${err.message}`);
        return -1
      }
    }
  }

  // 查询所有书籍数据
  async getAllRooms() {

    const rooms: room[] = [];
    const furnitureList: Furniture[] = [];
    const predicates_room = new relationalStore.RdbPredicates(this.TABLE_NAME);

    try {
      const resultSet = await this.rdbStore?.query(predicates_room);
      console.log('Rooms queried successfully.');
      if (resultSet?.rowCount == 0) {
        return [new room('null',[])]
      }

      while (resultSet?.goToNextRow()) {
        const room_id = resultSet.getLong(0);
        console.log('Room,,,furnitureId:' + JSON.stringify(room_id))
        //获取房间名字
        const room_name = resultSet.getString(1);

        //获取房间家居组
        const furnitures: Furniture[] = []
        const FurnitureResultSet = await this.rdbStore?.query(
          new relationalStore.RdbPredicates('Furniture')
            .equalTo('roomId', room_id),
          ['id', 'name', 'switch', 'roomId', 'type_id']
        )
        if (FurnitureResultSet?.goToFirstRow()) {
          do {
            const f_id = FurnitureResultSet.getLong(FurnitureResultSet.getColumnIndex('id'))
            const f_name = FurnitureResultSet.getString(FurnitureResultSet.getColumnIndex('name')).split(":")[0]
            const f_switch = FurnitureResultSet.getLong(FurnitureResultSet.getColumnIndex('switch'))
            const f_type = FurnitureResultSet.getLong(FurnitureResultSet.getColumnIndex('type_id'))
            furnitures.push(new Furniture(f_name, f_switch, f_type))
            console.log("Room" + f_name + f_switch)
          } while (FurnitureResultSet.goToNextRow())
        }
        FurnitureResultSet?.close()
        rooms.push(new room(room_name, furnitures))

      }
      resultSet?.close();
      console.log('Room,Rooms:' + JSON.stringify(rooms))
      return rooms;


    } catch (err) {
      console.error(`Failed to query books: ${err.message}`);

      return rooms
    }
  }
  async getAllFurinture_num() {

    let Num:number = 0


    const predicates_room = new relationalStore.RdbPredicates(this.TABLE_NAME);

    try {
      const resultSet = await this.rdbStore?.query(predicates_room);
      console.log('Rooms queried successfully.');


      while (resultSet?.goToNextRow()) {
        const room_id = resultSet.getLong(0);
        console.log('Room,,,furnitureId:' + JSON.stringify(room_id))
        const FurnitureResultSet = await this.rdbStore?.query(
          new relationalStore.RdbPredicates('Furniture')
            .equalTo('roomId', room_id),
          ['id', 'name', 'switch', 'roomId', 'type_id']
        )

        if (FurnitureResultSet?.goToFirstRow()) {
          do {

            Num++
          } while (FurnitureResultSet.goToNextRow())
        }
        FurnitureResultSet?.close()
      }
      resultSet?.close();
      return Num


    } catch (err) {
      console.error(`Failed to query books: ${err.message}`);
      return Num
    }
  }
  async getAllFurinture() {


    const Fs:Furniture[] = []

    const predicates_room = new relationalStore.RdbPredicates(this.TABLE_NAME);

    try {
      const resultSet = await this.rdbStore?.query(predicates_room);
      console.log('Rooms queried successfully.');


      while (resultSet?.goToNextRow()) {
        const room_id = resultSet.getLong(0);
        console.log('Room,,,furnitureId:' + JSON.stringify(room_id))
        const FurnitureResultSet = await this.rdbStore?.query(
          new relationalStore.RdbPredicates('Furniture')
            .equalTo('roomId', room_id),
          ['id', 'name', 'switch', 'roomId', 'type_id']
        )

        if (FurnitureResultSet?.goToFirstRow()) {
          do {
            const f_id = FurnitureResultSet.getLong(FurnitureResultSet.getColumnIndex('id'))
            const f_name = FurnitureResultSet.getString(FurnitureResultSet.getColumnIndex('name')).split(":")[0]
            const f_switch = FurnitureResultSet.getLong(FurnitureResultSet.getColumnIndex('switch'))
            const f_type = FurnitureResultSet.getLong(FurnitureResultSet.getColumnIndex('type_id'))
            Fs.push(new Furniture(f_name, f_switch, f_type))

          } while (FurnitureResultSet.goToNextRow())
        }
        FurnitureResultSet?.close()
      }
      resultSet?.close();
      return Fs


    } catch (err) {
      console.error(`Failed to query books: ${err.message}`);
      return Fs
    }
  }

  async getRoomById(id: number) {
    let _room: room = new room('', [])
    const RoomResultSet =
      await this.rdbStore?.query(new relationalStore.RdbPredicates(this.TABLE_NAME).equalTo('id', id), ['id', 'name'])
    while (RoomResultSet?.goToNextRow()) {
      const room_id = RoomResultSet.getLong(0);
      console.log('Room,,,furnitureId:' + JSON.stringify(room_id))
      //获取房间名字
      const room_name = RoomResultSet.getString(1);

      //获取房间家居组
      const furnitures: Furniture[] = []
      const FurnitureResultSet = await this.rdbStore?.query(
        new relationalStore.RdbPredicates('Furniture')
          .equalTo('roomId', room_id),
        ['id', 'name', 'switch', 'roomId','type_id']
      )
      if (FurnitureResultSet?.goToFirstRow()) {
        do {
          const f_id = FurnitureResultSet.getLong(FurnitureResultSet.getColumnIndex('id'))
          const f_name = FurnitureResultSet.getString(FurnitureResultSet.getColumnIndex('name')).split(":")[0]
          const f_switch = FurnitureResultSet.getLong(FurnitureResultSet.getColumnIndex('switch'))
          const f_type = FurnitureResultSet.getLong(FurnitureResultSet.getColumnIndex('type_id'))
          furnitures.push(new Furniture(f_name, f_switch, f_type))
          console.log("Room" + f_name + f_switch)
        } while (FurnitureResultSet.goToNextRow())
      }
      FurnitureResultSet?.close()
      _room = new room(room_name, furnitures)

    }
    RoomResultSet?.close();
    return _room
  }

  async getFurnitureByR_Id(id: number) {

    console.log("Q_Room is  ..ing1")
    const furnitures: Furniture[] = []
    const FurnitureResultSet = await this.rdbStore?.query(
      new relationalStore.RdbPredicates('Furniture')
        .equalTo('roomId', id),
      ['id', 'name', 'switch', 'roomId','type_id']
    )
    console.log("Q_Room is  ..ing2")
    if (FurnitureResultSet?.goToNextRow()) {
      FurnitureResultSet.goToFirstRow()
      do{
        const f_id = FurnitureResultSet.getLong(FurnitureResultSet.getColumnIndex('id'))
        const f_name = FurnitureResultSet.getString(FurnitureResultSet.getColumnIndex('name')).split(":")[0]
        const f_switch = FurnitureResultSet.getLong(FurnitureResultSet.getColumnIndex('switch'))
        const f_type = FurnitureResultSet.getLong(FurnitureResultSet.getColumnIndex('type_id'))
        furnitures.push(new Furniture(f_name, f_switch, f_type))
        console.log("Room" + f_name + f_switch)
      }while (FurnitureResultSet.goToNextRow())
    } else {
      console.log("Q_Room is fail")
    }
    console.log("Q_Room is  ..ing3")
    FurnitureResultSet?.close()
    console.log("Q_Room is" + JSON.stringify(furnitures))


    return furnitures
  }

  async getRoomsIdByName(name: string): Promise<number> {

    console.log('roomwwwwww ing 1')
    const _room: room = new room('', []);
    const furnitureList: Furniture[] = [];
    const predicates_room = new relationalStore.RdbPredicates(this.TABLE_NAME);
    console.log('roomwwwwww ing 2')
    try {
      const resultSet = await this.rdbStore?.query(predicates_room);
      console.log('Rooms queried successfully.');


      while (resultSet?.goToNextRow()) {
        const room_id = resultSet.getLong(0);
        console.log('Room,,,furnitureId:' + JSON.stringify(room_id))
        //获取房间名字
        const room_name = resultSet.getString(1);

        if (room_name == name) {
          return room_id
        }
      }
      resultSet?.close();
      console.log('Room,Rooms:' + JSON.stringify(_room))
      return -1;


    } catch (err) {
      console.error(`Failed to query books: ${err.message}`);

      return -1
    }
  }


  async renameFurnitureBy_RIdAndName(r_id: number, name: string, new_name: string) {
    if (!this.rdbStore) {
      console.error('Database is not initialized.');
      return 0;
    }
    try {

      const sql = 'UPDATE Furniture SET name = ? WHERE roomId =? AND name =?';
      const params = [new_name + ':' + r_id, r_id, name + ':' + r_id];
      await this.rdbStore.executeSql(sql, params);
      console.log("Room update success:" + new_name + ':' + r_id, r_id, name + ':' + r_id)

      return 1
    } catch (err) {
      console.error(`Failed to delete furniture: ${err.message}`);
      return -1
    }


  }


  async deleteFurnitureByRoomIdAndName(roomId: number, name: string) {
    if (!this.rdbStore) {
      console.error('Database is not initialized.');
      return;
    }
    try {
      const sql = 'DELETE FROM Furniture WHERE roomId =? AND name =?';
      const params = [roomId, name + ':' + roomId];
      await this.rdbStore.executeSql(sql, params);
      console.log(`Furniture with roomId ${roomId} and name ${name} deleted successfully.`);
    } catch (err) {
      console.error(`Failed to delete furniture: ${err.message}`);
    }
  }

  async clear() {
    try {
      if (!this.rdbStore) {
        console.error('Database is not initialized.');
        return;
      }
      // 清空 Furniture 表中的数据
      await this.rdbStore.executeSql('DELETE FROM Furniture');
      // 清空 Room 表中的数据
      await this.rdbStore.executeSql('DELETE FROM Room');
      console.log('All data in the tables has been cleared.');
    } catch (err) {
      console.error(`Failed to clear data: ${err.message}`);
    }
  }

  // 根据 ID 查询书籍数据

}


